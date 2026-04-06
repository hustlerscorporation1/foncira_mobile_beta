import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    final path = prefs.getString("profileImagePath");
    final savedName = prefs.getString("name");
    final savedCountry = prefs.getString("country");
    final savedPhone = prefs.getString("phone");
    final savedEmail = prefs.getString("email");
    final savedBio = prefs.getString("bio");

    setState(() {
      if (path != null) image = File(path);
      if (savedName != null) name = savedName;
      if (savedCountry != null) country = savedCountry;
      if (savedPhone != null) phone = savedPhone;
      if (savedEmail != null) email = savedEmail;
      if (savedBio != null) bio = savedBio;
    });
  }

  File? image;

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) {
        return;
      }

      //final imagetemp = File(image.path);
      final imagePermanent = await saveImagePermanently(image.path);
      setState(() {
        this.image = imagePermanent;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("profileImagePath", imagePermanent.path);
    } on PlatformException catch (e) {
      if (!mounted) return;
      print("Erreur lors de la sélection de l’image: $e");
    }
  }

  Future<void> _saveField(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');

    return File(imagePath).copy(image.path);
  }

  String name = "APETOGBO Ayao Christ-Joël";
  String country = "Togo";
  String phone = "+228 97 97 97 97";
  String email = "joel@example.com";
  String bio =
      "Citoyen Togolais résident au Togo. Informaticien passionné, père de famille.";

  final picker = ImagePicker();

  // ---- Calcul progression ----
  int _calculateProgress() {
    int score = 0;
    if (image != null) score += 25;
    if (name.isNotEmpty) score += 25;
    if (bio.isNotEmpty) score += 25;
    if (email.isNotEmpty && phone.isNotEmpty) score += 25;
    return score;
  }

  void _editField(
    BuildContext context,
    String title,
    String currentValue,
    Function(String) onSave,
  ) {
    TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Modifier $title"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Annuler"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Profil"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---- PROFIL HEADER ----
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: image != null
                              ? FileImage(image!)
                              : null,
                          child: image == null
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),

                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => pickImage(ImageSource.gallery),

                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Résident au $country",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress / 100,
                            color: Colors.green,
                            backgroundColor: Colors.grey.shade300,
                          ),
                          Text(
                            "Profil : $progress%",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---- INFOS PERSONNELLES ----
            _buildInfoCard("Nom", name, () {
              _editField(
                context,
                "Nom",
                name,
                (val) => setState(() {
                  name = val;
                  _saveField("name", val);
                }),
              );
            }),
            _buildInfoCard("Pays", country, () {
              _editField(
                context,
                "Pays",
                country,
                (val) => setState(() {
                  country = val;
                  _saveField("country", val);
                }),
              );
            }),
            _buildInfoCard("Téléphone", phone, () {
              _editField(
                context,
                "Téléphone",
                phone,
                (val) => setState(() {
                  phone = val;
                  _saveField("phone", val);
                }),
              );
            }),
            _buildInfoCard("Email", email, () {
              _editField(
                context,
                "Email",
                email,
                (val) => setState(() {
                  email = val;
                  _saveField("email", val);
                }),
              );
            }),

            const SizedBox(height: 20),

            // ---- BIO ----
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.green),
                title: const Text("Bio"),
                subtitle: Text(bio),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () {
                    _editField(
                      context,
                      "Bio",
                      bio,
                      (val) => setState(() {
                        bio = val;
                        _saveField("bio", val);
                      }),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ---- ZONE DE DANGER ----
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              label: const Text(
                "Supprimer mon compte",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Helper pour infos ----
  Widget _buildInfoCard(String title, String value, VoidCallback onEdit) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.green),
        title: Text(title),
        subtitle: Text(value),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.grey),
          onPressed: onEdit,
        ),
      ),
    );
  }
}
