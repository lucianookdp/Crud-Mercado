import 'package:flutter/material.dart';
import 'package:crud_mercado/models/alimento.dart';
import 'package:crud_mercado/helpers/sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRUD Restaurante',
      theme: ThemeData(
        primarySwatch: Colors.red, // Cor principal ajustada para o tema do restaurante
        appBarTheme: const AppBarTheme(
          color: Color(0xFFB71C1C), // Vermelho mais escuro para o cabeçalho
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFB71C1C), // Vermelho mais escuro para o FAB
        ),
        cardColor: const Color(0xFFFDEEDC), // Tons terrosos para os cards
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();

  List<Alimento> _alimentos = [];
  bool _isLoading = false;

  Future<void> _loadAlimentos() async {
    setState(() => _isLoading = true);
    final alimentos = await SqlHelper().getAllAlimentos();
    setState(() {
      _alimentos = alimentos;
      _isLoading = false;
    });
  }

  Future<void> _addAlimento() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Item'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Prato',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome do prato';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _precoController,
                  decoration: const InputDecoration(
                    labelText: 'Preço',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o preço';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Por favor, insira um preço válido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFFB71C1C)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await SqlHelper().insertAlimento(
                    Alimento(
                      nome: _nomeController.text,
                      preco: double.parse(_precoController.text),
                    ),
                  );
                  _nomeController.clear();
                  _precoController.clear();
                  Navigator.of(context).pop();
                  await _loadAlimentos();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C), // Alterado de 'primary' para 'backgroundColor'
              ),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAlimento(int id) async {
    final alimento = _alimentos.firstWhere((element) => element.id == id);
    setState(() => _isLoading = true);
    await SqlHelper().updateAlimento(alimento);
    await _loadAlimentos();
  }

  Future<void> _deleteAlimento(int id) async {
    setState(() => _isLoading = true);
    await SqlHelper().deleteAlimento(id);
    await _loadAlimentos();
  }

  @override
  void initState() {
    super.initState();
    _loadAlimentos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cardápio do Restaurante'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: _alimentos.length,
                itemBuilder: (context, index) {
                  final alimento = _alimentos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        alimento.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        'Preço: R\$${alimento.preco.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.green),
                            onPressed: () => _updateAlimento(alimento.id!),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteAlimento(alimento.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlimento,
        tooltip: 'Adicionar Prato',
        child: const Icon(Icons.add),
      ),
    );
  }
}
