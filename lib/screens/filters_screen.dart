import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class FiltersScreen extends StatefulWidget {
  final String childId;
  const FiltersScreen({super.key, required this.childId});
  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}
class _FiltersScreenState extends State<FiltersScreen> {
  final _valueController = TextEditingController();
  String _selectedType = 'block'; 
  bool _isLoading = false;
  late final Stream<QuerySnapshot> _rulesStream;
  @override
  void initState() {
    super.initState();
    _rulesStream = FirebaseFirestore.instance
        .collection('filter_rules')
        .where('childId', isEqualTo: widget.childId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  void _addRule() async {
    if (_valueController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    try {
      await FirebaseFirestore.instance.collection('filter_rules').add({
        'tutorId': uid,
        'childId': widget.childId,
        'type': _selectedType,
        'value': _valueController.text.trim().toLowerCase(),
        'isEnabled': true,
        'createdAt': Timestamp.now(),
      });
      _valueController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Regla añadida con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Configuración de Filtros:", 
            style: TextStyle(color: Color(0xFFA4A9B3), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _typeButton('Lista Negra', 'block'),
              _typeButton('Lista Blanca', 'allow'),
              _typeButton('Palabras', 'keyword'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _valueController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: _selectedType == 'keyword' 
                        ? 'Ej: apuestas, violencia' 
                        : 'Ej: facebook.com, youtube.com',
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFF222630),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE03131),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _addRule,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Reglas Activas',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _rulesStream, 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No hay reglas configuradas.', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  );
                }
                final rules = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: rules.length,
                  itemBuilder: (context, index) {
                    final doc = rules[index];
                    final rule = doc.data() as Map<String, dynamic>;
                    final ruleId = doc.id;
                    IconData icon;
                    Color iconColor;
                    if (rule['type'] == 'block') {
                      icon = Icons.block;
                      iconColor = const Color(0xFFE03131);
                    } else if (rule['type'] == 'allow') {
                      icon = Icons.check_circle;
                      iconColor = Colors.green;
                    } else {
                      icon = Icons.abc;
                      iconColor = Colors.amber;
                    }
                    return Card(
                      color: const Color(0xFF222630),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: Icon(icon, color: iconColor),
                        title: Text(
                          rule['value'] ?? '',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                        subtitle: Text(
                          rule['type'] == 'block' 
                              ? 'Bloqueado' 
                              : rule['type'] == 'allow' ? 'Permitido' : 'Palabra Prohibida',
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: rule['isEnabled'] ?? true,
                              activeColor: const Color(0xFFE03131),
                              onChanged: (value) async {
                                await FirebaseFirestore.instance
                                    .collection('filter_rules')
                                    .doc(ruleId)
                                    .update({'isEnabled': value});
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.white38, size: 18),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('filter_rules')
                                    .doc(ruleId)
                                    .delete();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _typeButton(String label, String type) {
    final bool isSelected = _selectedType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFFE03131),
      backgroundColor: const Color(0xFF222630),
      showCheckmark: false,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white60, 
        fontWeight: FontWeight.bold, 
        fontSize: 11
      ),
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedType = type;
          });
        }
      },
    );
  }
}