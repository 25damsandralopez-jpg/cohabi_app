import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_colors.dart';
import 'property_completed_screen.dart';

class RoomPhotosScreen extends StatefulWidget {
  final String propertyId;
  final int roomCount;
  final int roomIndex;
  final String roomId;

  const RoomPhotosScreen({
    super.key,
    required this.propertyId,
    required this.roomCount,
    required this.roomIndex,
    required this.roomId,
  });

  @override
  State<RoomPhotosScreen> createState() =>
      _RoomPhotosScreenState();
}

class _RoomPhotosScreenState extends State<RoomPhotosScreen> {
  final ImagePicker _picker = ImagePicker();

  final List<XFile?> _photos = [
    null,
    null,
    null,
    null,
  ];

  Future<void> _pickPhoto(int index) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    if (!mounted) return;

    setState(() {
      _photos[index] = image;
    });
  }

  void _removePhoto(int index) {
    setState(() {
      _photos[index] = null;
    });
  }

  Future<void> _continue() async {
    if (_photos[0] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Añade al menos una foto principal de la habitación.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('No hay un usuario autenticado.');
      }

      for (int i = 0; i < _photos.length; i++) {
        final photo = _photos[i];

        if (photo == null) continue;

        final bytes = await photo.readAsBytes();

        final extension = photo.path.contains('.')
            ? photo.path.split('.').last.toLowerCase()
            : 'jpg';

        final position = i + 1;

        final storagePath =
            '${user.id}/${widget.propertyId}/habitaciones/'
            'habitacion-${widget.roomIndex + 1}/$position.$extension';

        await supabase.storage
            .from('property-photos')
            .uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
          ),
        );

        final spaceType = 'habitacion-${widget.roomIndex + 1}';

        await supabase
            .from('property_photos')
            .delete()
            .eq('property_id', widget.propertyId)
            .eq('space_type', spaceType)
            .eq('position', position);

        await supabase.from('property_photos').insert({
          'property_id': widget.propertyId,
          'owner_id': user.id,
          'space_type': spaceType,
          'storage_path': storagePath,
          'position': position,
        });
      }

      // Cuando se guarda la última habitación, el piso queda publicado.
      if (widget.roomIndex + 1 >= widget.roomCount) {
        await supabase
            .from('properties')
            .update({'status': 'published'})
            .eq('id', widget.propertyId)
            .eq('owner_id', user.id);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Fotos de la habitación ${widget.roomIndex + 1} guardadas correctamente.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PropertyCompletedScreen(
            propertyId: widget.propertyId,
            roomCount: widget.roomCount,
            roomIndex: widget.roomIndex,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudieron guardar las fotos: $error',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            16,
            18,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: CohabiColors.navy,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: CohabiColors.navy,
                      size: 28,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              _buildStepIndicator(),

              const SizedBox(height: 22),

              const Text(
                'Fotos de la habitación',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Sube fotos de Habitación ${widget.roomIndex + 1} para que\n'
                    'los candidatos puedan conocerla mejor.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF5968A2),
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Fotos de la habitación',
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 14),

              GridView.builder(
                itemCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return _buildPhotoCard(index);
                },
              ),

              const SizedBox(height: 18),

              _buildTipsBox(),

              const SizedBox(height: 24),

              _buildContinueButton(),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CohabiColors.turquoise.withOpacity(0.12),
                CohabiColors.purple.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Paso 5',
                  style: TextStyle(
                    color: CohabiColors.turquoise,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: ' de 6',
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            6,
                (index) => Container(
              width: index < 5 ? 42 : 30,
              height: 5,
              margin: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              decoration: BoxDecoration(
                color: index < 5
                    ? CohabiColors.turquoise
                    : const Color(0xFFE1E3EB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(int index) {
    final photo = _photos[index];

    return InkWell(
      onTap: photo == null
          ? () => _pickPhoto(index)
          : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFDDE0E9),
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: photo != null
                    ? Image.file(
                  File(photo.path),
                  fit: BoxFit.cover,
                )
                    : Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: CohabiColors.turquoise
                            .withOpacity(0.08),
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: CohabiColors.turquoise,
                        size: 30,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      index == 0
                          ? 'Foto principal'
                          : 'Foto ${index + 1}',
                      style: const TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      index == 0
                          ? 'Obligatoria'
                          : 'Opcional',
                      style: const TextStyle(
                        color:
                        CohabiColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (photo != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _removePhoto(index),
                  child: Container(
                    width: 27,
                    height: 27,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
              ),

            if (photo != null)
              Positioned(
                left: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    index == 0
                        ? 'Principal'
                        : 'Foto ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsBox() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CohabiColors.purple.withOpacity(0.04),
            CohabiColors.purple.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: CohabiColors.purple,
            size: 28,
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consejos para buenas fotos',
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Usa luz natural, muestra la habitación completa '
                      'y mantén todo ordenado.',
                  style: TextStyle(
                    color: Color(0xFF5968A2),
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return InkWell(
      onTap: _continue,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: [
              CohabiColors.turquoise,
              Color(0xFF198DFF),
              CohabiColors.purple,
            ],
          ),
        ),
        child: const Row(
          children: [
            Spacer(),

            Text(
              'Guardar y continuar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            Spacer(),

            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 26,
            ),

            SizedBox(width: 17),
          ],
        ),
      ),
    );
  }
}