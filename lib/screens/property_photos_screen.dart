import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'property_rooms_screen.dart';

import '../core/theme/app_colors.dart';

class PropertyPhotosScreen extends StatefulWidget {
  final String propertyId;
  final int roomCount;

  const PropertyPhotosScreen({
    super.key,
    required this.propertyId,
    required this.roomCount,
  });

  @override
  State<PropertyPhotosScreen> createState() =>
      _PropertyPhotosScreenState();
}

class _PropertyPhotosScreenState extends State<PropertyPhotosScreen> {
  final ImagePicker _picker = ImagePicker();

  bool _isSaving = false;

  final List<_PhotoSpace> _spaces = [
    _PhotoSpace(
      'Salón / Comedor',
      Icons.chair_outlined,
    ),
    _PhotoSpace(
      'Cocina',
      Icons.soup_kitchen_outlined,
    ),
    _PhotoSpace(
      'Baño 1',
      Icons.bathtub_outlined,
    ),
    _PhotoSpace(
      'Baño 2',
      Icons.bathtub_outlined,
    ),
    _PhotoSpace(
      'Terraza / Balcón',
      Icons.deck_outlined,
    ),
    _PhotoSpace(
      'Zonas comunes',
      Icons.groups_outlined,
    ),
  ];

  // ============================================================
  // SELECCIONAR FOTOS
  // ============================================================

  Future<void> _addPhoto(int index) async {
    final space = _spaces[index];

    final remaining = 3 - space.photos.length;

    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ya has añadido el máximo de 3 fotos.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final images = await _picker.pickMultiImage(
      imageQuality: 85,
    );

    if (images.isEmpty) return;

    final selected = images.take(remaining).toList();

    if (!mounted) return;

    setState(() {
      space.photos.addAll(selected);
    });

    if (images.length > remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Solo puedes guardar un máximo de 3 fotos por estancia.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // AÑADIR OTRO ESPACIO
  // ============================================================

  void _addOtherSpace() {
    setState(() {
      _spaces.add(
        _PhotoSpace(
          'Otro espacio ${_spaces.length - 5}',
          Icons.add_home_work_outlined,
        ),
      );
    });
  }

  // ============================================================
  // CONVERTIR NOMBRE EN CARPETA
  // ============================================================

  String _spaceFolderName(String name) {
    return name
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(' / ', '-')
        .replaceAll('/', '-')
        .replaceAll(' ', '-');
  }

  // ============================================================
  // GUARDAR FOTOS EN SUPABASE
  // ============================================================

  Future<void> _savePhotos() async {
    if (_isSaving) return;

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay una sesión iniciada.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final totalPhotos = _spaces.fold<int>(
      0,
          (total, space) => total + space.photos.length,
    );

    if (totalPhotos == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Añade al menos una foto antes de continuar.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      for (final space in _spaces) {
        if (space.photos.isEmpty) continue;

        final spaceFolder = _spaceFolderName(space.name);

        for (int i = 0; i < space.photos.length; i++) {
          final photo = space.photos[i];

          final bytes = await photo.readAsBytes();

          final rawExtension = photo.path.contains('.')
              ? photo.path.split('.').last.toLowerCase()
              : 'jpg';

          final extension = rawExtension == 'jpeg'
              ? 'jpg'
              : rawExtension;

          final position = i + 1;

          final storagePath =
              '${user.id}/${widget.propertyId}/$spaceFolder/$position.$extension';

          // SUBIR ARCHIVO A STORAGE
          await supabase.storage
              .from('property-photos')
              .uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
            ),
          );

          // Evitamos duplicados si vuelve a pulsar guardar
          await supabase
              .from('property_photos')
              .delete()
              .eq(
            'property_id',
            widget.propertyId,
          )
              .eq(
            'space_type',
            spaceFolder,
          )
              .eq(
            'position',
            position,
          );

          // GUARDAR INFORMACIÓN DE LA FOTO
          await supabase
              .from('property_photos')
              .insert({
            'property_id': widget.propertyId,
            'owner_id': user.id,
            'space_type': spaceFolder,
            'storage_path': storagePath,
            'position': position,
          });
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Fotos guardadas correctamente.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PropertyRoomsScreen(
            propertyId: widget.propertyId,
            roomCount: widget.roomCount,
          ),
        ),
      );

    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al guardar las fotos: $error',
          ),
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: CohabiColors.navy,
                    size: 28,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              _buildStepIndicator(),

              const SizedBox(height: 24),

              const Text(
                'Fotos del piso',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Sube fotos de tu piso para que\n'
                    'los candidatos puedan conocerlo mejor.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 28),

              GridView.builder(
                itemCount: _spaces.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.60,
                ),
                itemBuilder: (context, index) {
                  return _buildPhotoCard(index);
                },
              ),

              const SizedBox(height: 18),

              _buildAddOtherSpace(),

              const SizedBox(height: 16),

              _buildTipsBox(),

              const SizedBox(height: 24),

              _buildContinueButton(),

              const SizedBox(height: 12),

              TextButton(
                onPressed: _isSaving
                    ? null
                    : () => Navigator.pop(context),
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

  // ============================================================
  // INDICADOR PASO 3
  // ============================================================

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
                  text: 'Paso 3',
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
              width: index < 3 ? 42 : 30,
              height: 5,
              margin: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              decoration: BoxDecoration(
                color: index < 3
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

  // ============================================================
  // TARJETA DE CADA ESTANCIA
  // ============================================================

  Widget _buildPhotoCard(int index) {
    final space = _spaces[index];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE3E5ED),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            space.icon,
            color: CohabiColors.turquoise,
            size: 38,
          ),

          const SizedBox(height: 10),

          Text(
            space.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              color: CohabiColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),

          const Spacer(),

          if (space.photos.isEmpty)
            InkWell(
              onTap: () => _addPhoto(index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFDDE0E9),
                  ),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: CohabiColors.navy,
                  size: 31,
                ),
              ),
            )
          else
            SizedBox(
              height: 58,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    space.photos.length,
                        (photoIndex) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius:
                              BorderRadius.circular(8),
                              child: Image.file(
                                File(
                                  space
                                      .photos[photoIndex]
                                      .path,
                                ),
                                width: 46,
                                height: 46,
                                fit: BoxFit.cover,
                              ),
                            ),

                            Positioned(
                              top: -7,
                              right: -7,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    space.photos.removeAt(
                                      photoIndex,
                                    );
                                  });
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration:
                                  const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  if (space.photos.length < 3)
                    Padding(
                      padding:
                      const EdgeInsets.only(left: 3),
                      child: InkWell(
                        onTap: () => _addPhoto(index),
                        borderRadius:
                        BorderRadius.circular(8),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(8),
                            border: Border.all(
                              color:
                              const Color(0xFFDDE0E9),
                            ),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: CohabiColors.navy,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          Text(
            space.photos.isNotEmpty
                ? '${space.photos.length} de 3 fotos'
                : 'Añadir fotos',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF53639B),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AÑADIR OTRO ESPACIO
  // ============================================================

  Widget _buildAddOtherSpace() {
    return InkWell(
      onTap: _addOtherSpace,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE3E5ED),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: CohabiColors.turquoise,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(width: 14),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Añadir otro espacio',
                    style: TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Despacho, jardín, trastero, garaje, etc.',
                    style: TextStyle(
                      color: CohabiColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CONSEJOS
  // ============================================================

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
                  'Usa luz natural, muestra los espacios completos\n'
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

          Icon(
            Icons.chevron_right_rounded,
            color: CohabiColors.navy,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTÓN GUARDAR
  // ============================================================

  Widget _buildContinueButton() {
    return InkWell(
      onTap: _isSaving
          ? null
          : () => _savePhotos(),
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
        child: Row(
          children: [
            const Spacer(),

            if (_isSaving)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            else
              const Text(
                'Guardar y continuar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),

            const Spacer(),

            if (!_isSaving)
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 26,
              ),

            const SizedBox(width: 17),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MODELO PARA CADA ESTANCIA
// ============================================================

class _PhotoSpace {
  final String name;
  final IconData icon;
  final List<XFile> photos;

  _PhotoSpace(
      this.name,
      this.icon, {
        List<XFile>? photos,
      }) : photos = photos ?? [];
}