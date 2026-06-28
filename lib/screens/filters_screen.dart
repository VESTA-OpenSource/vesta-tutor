import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FiltersScreen extends StatefulWidget {
  final String childId;
  final String tutorId;
  const FiltersScreen({super.key, required this.childId, required this.tutorId});

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
    // Acceso a la subcolección del hijo específico
    _rulesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.tutorId)
        .collection('hijos')
        .doc(widget.childId)
        .collection('filter_rules')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  void _addRule() async {
    if (_valueController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.tutorId)
          .collection('hijos')
          .doc(widget.childId)
          .collection('filter_rules')
          .add({
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
          const Text("Configuración de Filtros:", 
              style: TextStyle(color: Color(0xFFA4A9B3), fontWeight: FontWeight.bold)),
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
                    hintText: _selectedType == 'keyword' ? 'Ej: apuestas' : 'Ej: youtube.com',
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFF222630),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE03131)),
                      onPressed: _addRule,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _rulesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('Sin reglas.', style: TextStyle(color: Colors.white54)));
                
                final rules = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: rules.length,
                  itemBuilder: (context, index) {
                    final doc = rules[index];
                    final rule = doc.data() as Map<String, dynamic>;
                    return Card(
                      color: const Color(0xFF222630),
                      child: ListTile(
                        title: Text(rule['value'] ?? '', style: const TextStyle(color: Colors.white)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: rule['isEnabled'] ?? true,
                              onChanged: (val) => _updateRule(doc.id, val),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.white38),
                              onPressed: () => _deleteRule(doc.id),
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

  Future<void> _updateRule(String ruleId, bool isEnabled) async {
    await FirebaseFirestore.instance
        .collection('users').doc(widget.tutorId)
        .collection('hijos').doc(widget.childId)
        .collection('filter_rules').doc(ruleId)
        .update({'isEnabled': isEnabled});
  }

  Future<void> _deleteRule(String ruleId) async {
    await FirebaseFirestore.instance
        .collection('users').doc(widget.tutorId)
        .collection('hijos').doc(widget.childId)
        .collection('filter_rules').doc(ruleId)
        .delete();
  }

  Widget _typeButton(String label, String type) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedType == type,
      selectedColor: const Color(0xFFE03131),
      backgroundColor: const Color(0xFF222630),
      onSelected: (bool selected) => setState(() => _selectedType = type),
    );
  }
}