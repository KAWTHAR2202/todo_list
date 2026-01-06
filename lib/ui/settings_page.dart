import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionTitle(context, 'Apparence'),
          Card(
            child: Column(
              children: [
                // Dark Mode Toggle
                Obx(
                  () => SwitchListTile(
                    secondary: Icon(
                      themeController.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: colorScheme.primary,
                    ),
                    title: const Text('Mode sombre'),
                    subtitle: Text(
                      themeController.isDarkMode ? 'Activé' : 'Désactivé',
                    ),
                    value: themeController.isDarkMode,
                    onChanged: (value) => themeController.setDarkMode(value),
                  ),
                ),
                const Divider(height: 1),
                // Primary Color
                ListTile(
                  leading: Icon(Icons.palette, color: colorScheme.primary),
                  title: const Text('Couleur principale'),
                  subtitle: const Text('Personnalisez le thème'),
                  trailing: Obx(
                    () => Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: themeController.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  onTap: () => _showColorPicker(context, themeController),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionTitle(context, 'Notifications'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.notifications,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Notifications de tâches'),
                  subtitle: const Text('Rappels pour les tâches'),
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement notification settings
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(Icons.timer, color: colorScheme.primary),
                  title: const Text('Notifications Pomodoro'),
                  subtitle: const Text('Alertes de fin de session'),
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement pomodoro notification settings
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionTitle(context, 'À propos'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info, color: colorScheme.primary),
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.code, color: colorScheme.primary),
                  title: const Text('Développé avec'),
                  subtitle: const Text('Flutter & ❤️'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, ThemeController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une couleur'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ThemeController.availableColors.map((color) {
            return Obx(
              () => GestureDetector(
                onTap: () {
                  controller.setPrimaryColor(color);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: controller.primaryColor == color
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: controller.primaryColor == color
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: controller.primaryColor == color
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}
