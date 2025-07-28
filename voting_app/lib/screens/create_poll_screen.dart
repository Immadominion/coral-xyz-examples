import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/solana_voting_service.dart';
import '../widgets/gradient_button.dart';
import '../utils/theme.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({super.key});

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length < 4) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    }
  }

  Future<void> _createPoll() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final options = _optionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide at least 2 options'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final votingService = Provider.of<SolanaVotingService>(
      context,
      listen: false,
    );

    await votingService.createPoll(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      options: options,
    );

    if (votingService.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(votingService.error!),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Poll created successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Poll'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<SolanaVotingService>(
        builder: (context, votingService, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPollInfoSection(),
                  const SizedBox(height: AppTheme.spacingXL),
                  _buildOptionsSection(),
                  const SizedBox(height: AppTheme.spacingXXL),
                  GradientButton(
                    text: 'Create Poll',
                    icon: Icons.create,
                    isLoading: votingService.isLoading,
                    onPressed: _createPoll,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPollInfoSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Poll Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Poll Name',
              hintText: 'Enter a descriptive name for your poll',
              prefixIcon: Icon(Icons.title),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a poll name';
              }
              if (value.length > 50) {
                return 'Poll name must be 50 characters or less';
              }
              return null;
            },
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppTheme.spacingL),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Provide more details about your poll',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a description';
              }
              if (value.length > 200) {
                return 'Description must be 200 characters or less';
              }
              return null;
            },
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Poll Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const Spacer(),
              if (_optionControllers.length < 4)
                TextButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Option'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          ...List.generate(_optionControllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _optionControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Option ${index + 1}',
                        hintText: 'Enter option text',
                        prefixIcon: Icon(Icons.radio_button_unchecked),
                      ),
                      validator: (value) {
                        if (value != null &&
                            value.trim().isNotEmpty &&
                            value.length > 50) {
                          return 'Option must be 50 characters or less';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  if (_optionControllers.length > 2) ...[
                    const SizedBox(width: AppTheme.spacingS),
                    IconButton(
                      onPressed: () => _removeOption(index),
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppTheme.errorColor,
                    ),
                  ],
                ],
              ),
            );
          }),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    'You can add up to 4 options. Minimum 2 options required.',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
