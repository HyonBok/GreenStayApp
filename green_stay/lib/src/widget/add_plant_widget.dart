import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:green_stay/src/models/client_model.dart';
import 'package:green_stay/src/models/plant_create_model.dart';
import 'package:green_stay/src/models/plant_identification_model.dart';
import 'package:green_stay/src/repositories/client_repository.dart';
import 'package:green_stay/src/repositories/plant_repository.dart';
import 'package:image_picker/image_picker.dart';

class AddPlantPage extends StatefulWidget {
  final int userId;

  const AddPlantPage({super.key, required this.userId});

  @override
  State<AddPlantPage> createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  final _formKey = GlobalKey<FormState>();
  final _plantRepository = PlantRepository();
  final _clientRepository = ClientRepository();
  final _picker = ImagePicker();

  late Future<List<ClientModel>> _clientsFuture;

  final _nomeController = TextEditingController();
  final _especieController = TextEditingController();
  final _umidadeController = TextEditingController();
  final _luminosidadeController = TextEditingController();
  final _temperaturaController = TextEditingController();

  File? _selectedImage;
  bool _isIdentifying = false;
  bool _isSaving = false;
  int? _selectedClientId;
  double? _confidence;
  String? _identificationError;

  @override
  void initState() {
    super.initState();
    _clientsFuture = _clientRepository.fetchClientsByUser(widget.userId);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _especieController.dispose();
    _umidadeController.dispose();
    _luminosidadeController.dispose();
    _temperaturaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (picked == null) return;

      setState(() {
        _selectedImage = File(picked.path);
        _identificationError = null;
      });

      await _identifyPlant();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagem: $e')),
      );
    }
  }

  Future<void> _identifyPlant() async {
    final image = _selectedImage;
    if (image == null) {
      return;
    }

    setState(() {
      _isIdentifying = true;
      _identificationError = null;
      _confidence = null;
    });

    try {
      final PlantIdentificationModel identification =
          await _plantRepository.identifyPlant(image);

      setState(() {
        if (identification.nomePopular != null &&
            identification.nomePopular!.isNotEmpty) {
          _nomeController.text = identification.nomePopular!;
        } else if (identification.nomeCientifico != null &&
            identification.nomeCientifico!.isNotEmpty) {
          _nomeController.text = identification.nomeCientifico!;
        }

        if (identification.especie != null &&
            identification.especie!.isNotEmpty) {
          _especieController.text = identification.especie!;
        } else if (identification.nomeCientifico != null &&
            identification.nomeCientifico!.isNotEmpty) {
          _especieController.text = identification.nomeCientifico!;
        }

        if (identification.umidadeIdeal != null) {
          _umidadeController.text =
              identification.umidadeIdeal!.round().toString();
        }
        if (identification.luminosidadeIdeal != null) {
          _luminosidadeController.text =
              identification.luminosidadeIdeal!.round().toString();
        }
        if (identification.temperaturaIdeal != null) {
          _temperaturaController.text =
              identification.temperaturaIdeal!.round().toString();
        }
        _confidence = identification.confianca;
      });
    } catch (e) {
      setState(() {
        _identificationError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isIdentifying = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um cliente para a planta.')),
      );
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma imagem da planta.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      int parseOrZero(String value) => int.tryParse(value.trim()) ?? 0;

      final plant = PlantCreateModel(
        nome: _nomeController.text.trim(),
        especie: _especieController.text.trim(),
        clienteId: _selectedClientId!,
        umidade: parseOrZero(_umidadeController.text),
        luminosidade: parseOrZero(_luminosidadeController.text),
        temperatura: parseOrZero(_temperaturaController.text),
        base64: base64Image,
      );

      await _plantRepository.createPlant(plant);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar planta: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildImageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto da planta',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (_selectedImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _selectedImage!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey.shade400),
            ),
            alignment: Alignment.center,
            child: const Text('Nenhuma imagem selecionada'),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isIdentifying ? null : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Tirar foto'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    _isIdentifying ? null : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galeria'),
              ),
            ),
          ],
        ),
        if (_isIdentifying)
          const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: LinearProgressIndicator(),
          ),
        if (_confidence != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Confiança da identificação: ${(100 * _confidence!).clamp(0, 100).toStringAsFixed(1)}%',
            ),
          ),
        if (_identificationError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _identificationError!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
      ],
    );
  }

  Widget _buildForm(List<ClientModel> clients) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Cliente'),
            value: _selectedClientId,
            items: clients
                .map(
                  (client) => DropdownMenuItem<int>(
                    value: client.id,
                    child: Text(client.nome),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedClientId = value;
              });
            },
            validator: (value) => value == null ? 'Selecione um cliente' : null,
          ),
          TextFormField(
            controller: _nomeController,
            decoration: const InputDecoration(labelText: 'Nome da planta'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe o nome da planta';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _especieController,
            decoration: const InputDecoration(labelText: 'Espécie'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe a espécie';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _umidadeController,
            decoration: const InputDecoration(labelText: 'Umidade ideal (%)'),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            controller: _luminosidadeController,
            decoration:
                const InputDecoration(labelText: 'Luminosidade ideal (lux)'),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            controller: _temperaturaController,
            decoration:
                const InputDecoration(labelText: 'Temperatura ideal (°C)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _submit,
              icon: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isSaving ? 'Salvando...' : 'Cadastrar planta'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova planta'),
      ),
      body: FutureBuilder<List<ClientModel>>(
        future: _clientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      'Não foi possível carregar os clientes.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _clientsFuture =
                              _clientRepository.fetchClientsByUser(widget.userId);
                        });
                      },
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final clients = snapshot.data ?? [];
          if (clients.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_off_outlined,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhum cliente encontrado para este usuário.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _clientsFuture =
                              _clientRepository.fetchClientsByUser(widget.userId);
                        });
                      },
                      child: const Text('Recarregar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_selectedClientId == null) {
            _selectedClientId = clients.first.id;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSelector(),
                const SizedBox(height: 24),
                _buildForm(clients),
              ],
            ),
          );
        },
      ),
    );
  }
}
