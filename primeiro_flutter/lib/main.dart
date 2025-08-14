// Importamos os pacotes e os arquivos das telas que criámos.
import 'package:flutter/material.dart';
import 'package:primeiro_flutter/telas/tela_calendario.dart';
import 'package:primeiro_flutter/telas/tela_configuracao.dart';
import 'package:primeiro_flutter/telas/tela_home.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // A tela inicial do nosso app agora é a TelaPrincipal, que controla a navegação.
      home: TelaPrincipal(),
    );
  }
}

// Este widget precisa de ser um StatefulWidget.
// Motivo: Ele precisa de guardar uma informação que vai mudar: o índice da tela selecionada.
// Quando o índice mudar, a tela precisa de se redesenhar para mostrar o conteúdo novo.
class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  // Variável para guardar o índice da aba atualmente selecionada. Começa em 0 (a primeira tela).
  int _indiceSelecionado = 0;

  // Lista com as telas que vamos exibir. A ordem aqui importa!
  static const List<Widget> _telas = <Widget>[
    TelaHome(),
    TelaCalendario(),
    TelaConfiguracao(),
  ];

  // Função chamada quando o usuário toca em um item da barra de navegação.
  void _onItemTapped(int index) {
    // setState é a função que diz ao Flutter: "Ei, uma variável de estado mudou!
    // Por favor, redesenhe a tela para refletir essa mudança."
    setState(() {
      _indiceSelecionado = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O corpo da nossa tela principal agora é a tela que está na posição `_indiceSelecionado` da nossa lista.
      body: Center(
        child: _telas.elementAt(_indiceSelecionado),
      ),
      // Aqui adicionamos a nossa barra de navegação inferior.
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendário',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
        currentIndex: _indiceSelecionado, // O item atualmente selecionado.
        onTap: _onItemTapped, // A função que será chamada ao tocar.
      ),
    );
  }
}
