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
  State<RoomPhotosScreen> createState() => _RoomPhotosScreenState();
}

class _RoomPhotosScreenState extends State<RoomPhotosScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile?> _photos = [null, null, null, null];

  bool _isSaving = false;

  Future<void> _pickPhoto(int index) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null || !mounted) return;

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
          content: Text('Añade al menos una foto principal de la habitación.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('No hay un usuario autenticado.');
      }

      final spaceType = 'habitacion-${widget.roomIndex + 1}';

      for (int i = 0; i < _photos.length; i++) {
        final photo = _photos[i];
        if (photo == null) continue;

        final bytes = await photo.readAsBytes();

        final rawExtension = photo.path.contains('.')
            ? photo.path.split('.').last.toLowerCase()
            : 'jpg';

        final extension = rawExtension == 'jpeg' ? 'jpg' : rawExtension;
        final position = i + 1;

        final storagePath =
            '${user.id}/${widget.propertyId}/habitaciones/'
            '$spaceType/$position.$extension';

        await supabase.storage.from('property-photos').uploadBinary(
              storagePath,
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );

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

      final isLastRoom = widget.roomIndex + 1 >= widget.roomCount;

      if (isLastRoom) {
        await supabase
            .from('properties')
            .update({
              'status': 'published',
            })
            .eq('id', widget.propertyId)
            .eq('owner_id', user.id);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isLastRoom
                ? 'Piso publicado correctamente.'
                : 'Fotos de la habitación ${widget.roomIndex + 1} guardadas correctamente.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PropertyCompletedScreen(
            propertyId: widget.propertyId,
            roomCount: widget.roomCount,
            roomIndex: widget.roomIndex,
          ),
        ),
      );
    } on StorageException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudieron subir las fotos: ${error.message}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on PostgrestException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudieron guardar los datos: ${error.message}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudieron guardar las fotos: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
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
                'Habitación ${widget.roomIndex + 1}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CohabiColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'Añade fotos de la habitación',
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'La primera imagen será la foto principal de la habitación.',
                style: TextStyle(
                  color: CohabiColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _photos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (_, index) => _buildPhotoCard(index),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        CohabiColors.turquoise,
                        CohabiColors.purple,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Guardar y continuar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                              ),
                            ],
                          ),
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
        const Text(
          'Paso 6 de 6',
          style: TextStyle(
            color: CohabiColors.purple,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(
            6,
            (index) => Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(right: index == 5 ? 0 : 6),
                decoration: BoxDecoration(
                  color: CohabiColors.turquoise,
                  borderRadius: BorderRadius.circular(20),
                ),
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
      onTap: () => _pickPhoto(index),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: photo != null
                ? CohabiColors.turquoise
                : CohabiColors.border,
            width: photo != null ? 1.5 : 1,
          ),
        ),
        child: photo == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: CohabiColors.turquoise.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: CohabiColors.turquoise,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    index == 0 ? 'Foto principal' : 'Añadir foto',
                    style: const TextStyle(
                      color: CohabiColors.navy,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Image.file(
                      File(photo.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () => _removePhoto(index),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: CohabiColors.navy,
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Principal',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
