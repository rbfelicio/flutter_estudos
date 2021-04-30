import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Contato.dart';
import 'DataBaseHelper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Contatos',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: ListaDeContatos(titulo: 'Lista de Contatos'),
    );
  }
}

class ListaDeContatos extends StatefulWidget {
  ListaDeContatos({Key key, this.titulo}) : super(key: key);
  final String titulo;

  @override
  _ListaDeContatosState createState() => _ListaDeContatosState();
}

class _ListaDeContatosState extends State<ListaDeContatos> {
  final _email = TextEditingController();
  final _nome = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  static DatabaseHelper banco;

  int tamanhoDaLista = 0;
  List<Contato> listaDeContatos;

  @override
  void initState() {
    banco = new DatabaseHelper();
    banco.inicializaBanco();
    Future<List<Contato>> listaDeContatos = banco.getListaDeContato();
    listaDeContatos.then((novaListaDeContatos) {
      setState(() {
        this.listaDeContatos = novaListaDeContatos;
        this.tamanhoDaLista = novaListaDeContatos.length;
      });
    });
  }


  _carregarLista() {

    banco = new DatabaseHelper();
    banco.inicializaBanco();

    Future<List<Contato>> noteListFuture = banco.getListaDeContato();
    noteListFuture.then((novaListaDeContatos) {

      setState(() {
        this.listaDeContatos = novaListaDeContatos;
        this.tamanhoDaLista = novaListaDeContatos.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
      ),
      body: _listaDeContatos(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _adicionarContato(); //chamo o AlertDialog
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.indigoAccent,
      ),
    );
  }

  void _removerItem(Contato contato, int index) {
    setState(() {

      listaDeContatos = List.from(listaDeContatos)..removeAt(index);
      banco.apagarContato(contato.id);
      tamanhoDaLista = tamanhoDaLista - 1;
    });
  }

  void _adicionarContato() {
    _email.text = '';
    _nome.text = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Novo Contato"),
          content: new Container(
            child: new Form(
              key: _formKey,
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  campoDeNome(),
                  Divider(
                    color: Colors.transparent,
                    height: 20.0,
                  ),
                  campoDeEmail()
                ],
              ),
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Salvar"),
              onPressed: () {
                Contato _contato;
                if (_formKey.currentState.validate()) {
                  _contato = new Contato(_nome.text, _email.text);
                  banco.inserirContato(_contato);
                  _carregarLista();
                  _formKey.currentState.reset();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _atualizarContato(Contato contato) {
    _email.text = contato.email;
    _nome.text = contato.nome;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Detalhes do  Contato"),
          content: new Container(
            child: new Form(
              key: _formKey,
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  campoDeNome(),
                  Divider(
                    color: Colors.transparent,
                    height: 20.0,
                  ),
                  campoDeEmail()
                ],
              ),
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Atualizar"),
              onPressed: () {
                Contato _contato;

                if (_formKey.currentState.validate()) {
                  _contato = new Contato(_nome.text, _email.text);
                  banco.atualizarContato(_contato, contato.id);
                  _carregarLista();
                  _formKey.currentState.reset();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget campoDeNome() {
    return new TextFormField(
      controller: _nome,
      keyboardType: TextInputType.text,
      validator: (valor) {
        if (valor.isEmpty && valor.length == 0) {
          return "Campo Obrigatório";
        }
      },
      decoration: new InputDecoration(
        hintText: 'Nome',
        labelText: 'Nome completo',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget campoDeEmail() {
    return new TextFormField(
      controller: _email,
      validator: (valor) {
        if (valor.isEmpty && valor.length == 0) {
          return "Campo Obrigatório";
        }
      },
      decoration: new InputDecoration(
        hintText: 'Email',
        labelText: 'Email',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _listaDeContatos() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: tamanhoDaLista,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: ListTile(

            title: Text(listaDeContatos[index].nome),

            subtitle: Text(listaDeContatos[index].email),

            leading: CircleAvatar(

              child: Text(listaDeContatos[index].nome[0]),
            ),
          ),
          onTap: () => _atualizarContato(listaDeContatos[index]),
          onLongPress: () => _removerItem(listaDeContatos[0], index),
        );
      },
    );
  }
}
