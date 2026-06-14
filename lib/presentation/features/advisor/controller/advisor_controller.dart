import 'package:flutter/material.dart';
import '../../../../services/ai_advisor_service.dart';
import '../../score/controller/score_controller.dart';
import '../../settings/controller/settings_controller.dart';
import '../../transactions/controller/transactions_controller.dart';
import '../../debts/controller/debts_controller.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class AdvisorController extends ChangeNotifier {
  final AiAdvisorService _aiService = AiAdvisorService();
  final ScoreController _scoreController;
  final SettingsController _settingsController;
  final TransactionsController _txController;
  final DebtsController _debtsController;

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  bool _contextInjected = false;

  AdvisorController(
      this._scoreController, 
      this._settingsController,
      this._txController,
      this._debtsController);

  void _injectContextIfNeeded() {
    if (_contextInjected) return;

    // Construir un resumen del contexto del usuario
    final totalResult = _scoreController.totalResult;
    final factors = _scoreController.lifetimeFactors;
    final monthlyResult = _scoreController.monthlyResult;
    final monthlyFactors = _scoreController.monthlyFactors;
    
    final incomeType = _settingsController.profile?.incomeType ?? 'No definido';
    final savingsTarget = _settingsController.profile?.savingsTarget ?? 0;

    String contextStr = "El usuario tiene un tipo de ingreso: $incomeType. Su meta de ahorro es $savingsTarget%. ";

    if (monthlyFactors != null) {
      contextStr += "MES ACTUAL: Tasa de ahorro ${monthlyFactors.savingsRate.toStringAsFixed(1)}%, ";
      contextStr += "Utilización de crédito ${monthlyFactors.utilization.toStringAsFixed(1)}%, ";
      contextStr += "Deuda/Ingreso ${monthlyFactors.debtToIncome.toStringAsFixed(1)}%, ";
      contextStr += "Días de atraso (DPD) ${monthlyFactors.dpd}. ";
    }
    if (monthlyResult != null) {
      contextStr += "Puntaje del mes: ${monthlyResult.score}/100 (${monthlyResult.status}). ";
    }

    if (factors != null) {
      contextStr += "HISTÓRICO: Tasa de ahorro ${factors.savingsRate.toStringAsFixed(1)}%, ";
      contextStr += "Utilización ${factors.utilization.toStringAsFixed(1)}%, ";
      contextStr += "Deuda/Ingreso ${factors.debtToIncome.toStringAsFixed(1)}%. ";
    }

    if (totalResult != null) {
      contextStr += "Puntaje histórico: ${totalResult.score}/100 (${totalResult.status}). ";
    }

    // Agregar valores absolutos del mes actual para que la IA no los pregunte
    final now = DateTime.now();
    final monthTx = _txController.items.where((t) => t.date.month == now.month && t.date.year == now.year).toList();
    
    double incomes = 0;
    double expenses = 0;
    Map<String, double> expensesByCategory = {};
    
    for (var tx in monthTx) {
      if (tx.type == 'income') {
        incomes += tx.amount;
      } else if (tx.type == 'expense') {
        final amountAbs = tx.amount.abs();
        expenses += amountAbs;
        expensesByCategory[tx.category] = (expensesByCategory[tx.category] ?? 0) + amountAbs;
      }
    }
    contextStr += "VALORES ABSOLUTOS (Mes actual): Ingresos Totales: S/$incomes, Gastos Totales: S/$expenses. ";
    if (expensesByCategory.isNotEmpty) {
      contextStr += "Desglose de gastos por categoría: ";
      expensesByCategory.forEach((cat, amount) {
        contextStr += "$cat (S/$amount), ";
      });
    }

    final activeDebts = _debtsController.items.where((d) => !d.paid).toList();
    if (activeDebts.isNotEmpty) {
      contextStr += "Lista de Deudas Activas: ";
      for (var d in activeDebts) {
        contextStr += "${d.title} (Cuota: S/${d.amount}, Total Deuda: S/${d.totalDebt}), ";
      }
    } else {
      contextStr += "Actualmente no tiene deudas activas registradas. ";
    }

    // Pasamos el contexto al servicio de Gemini
    debugPrint("======== CONTEXTO ENVIADO A GEMINI ========");
    debugPrint(contextStr);
    debugPrint("===========================================");
    
    _aiService.startChatWithContext(contextStr);
    _contextInjected = true;
    
    // Agregamos el mensaje de bienvenida de la IA
    _messages.add(
      ChatMessage(
        text: '¡Hola! Soy tu Asesor Financiero Inteligente. He analizado tu situación actual en la aplicación. ¿En qué te puedo ayudar hoy?',
        isUser: false,
        timestamp: DateTime.now(),
      )
    );
    notifyListeners();
  }

  /// Limpia el chat y vuelve a inyectar el contexto actualizado
  void resetChat() {
    _messages.clear();
    _contextInjected = false;
    _injectContextIfNeeded();
  }

  /// Envía un mensaje a la IA
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _injectContextIfNeeded();

    final userMsg = ChatMessage(text: text, isUser: true, timestamp: DateTime.now());
    _messages.add(userMsg);
    _isTyping = true;
    notifyListeners();

    try {
      final responseText = await _aiService.sendMessage(text);
      final aiMsg = ChatMessage(text: responseText, isUser: false, timestamp: DateTime.now());
      _messages.add(aiMsg);
    } catch (e) {
      _messages.add(ChatMessage(
        text: "Hubo un problema al contactar con mis servidores. Asegúrate de tener conexión y que la API Key esté configurada correctamente.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  // Se llama cuando la pantalla de asesor se inicia para mostrar el saludo inicial
  Future<void> initChat() async {
    if (_messages.isEmpty) {
      _isTyping = true;
      notifyListeners();

      // 1. Cargar Transacciones si no se han cargado (versión == 0)
      if (_txController.version == 0) {
        await _txController.load();
      }

      // 2. Cargar Deudas si no se han cargado (versión == 0)
      if (_debtsController.version == 0) {
        await _debtsController.load();
      }

      // 3. Cargar o esperar ScoreController
      // Si el ProxyProvider disparó el load, esperamos.
      while (_scoreController.loading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Asegurarnos de que ScoreController tenga los datos más recientes
      if (_scoreController.lifetimeFactors == null || 
          _scoreController.lastSyncedTxVersion != _txController.version ||
          _scoreController.lastSyncedDebtVersion != _debtsController.version) {
        await _scoreController.load(
          txVersion: _txController.version, 
          debtVersion: _debtsController.version
        );
      }

      _injectContextIfNeeded();
      
      _isTyping = false;
      notifyListeners();
    }
  }
}
