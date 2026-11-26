# EPI HC — Controle de Entregas de EPI

Aplicativo Android em **Flutter** para registrar a entrega de Equipamentos de
Proteção Individual (EPI) aos colaboradores. É uma extensão da
HC Assessoria de Segurança do Trabalho e segue a identidade visual do site (logo, azul `#00ADEF` sobre neutros frios,
títulos em Archivo, rótulos em Oswald e texto em Public Sans).

Trabalho da disciplina de Desenvolvimento para Dispositivos Móveis (UDESC Alto Vale).

## Funcionalidades (requisitos funcionais)

| # | Requisito |
|---|-----------|
| RF01 | Login com e-mail e senha; a sessão fica salva entre aberturas do app |
| RF02 | Cadastro de novo usuário (responsável pelas entregas) |
| RF03 | Painel com indicadores: entregas no mês, colaboradores ativos, EPIs com estoque baixo e CAs vencidos |
| RF04 | Alerta de trocas de EPI vencidas ou que vencem em até 15 dias, calculadas pela periodicidade de cada EPI |
| RF05 | Cadastro, edição, busca e inativação de colaboradores (CPF validado) |
| RF06 | Ficha do colaborador com o histórico de EPIs recebidos |
| RF07 | Cadastro de EPIs com nº do CA, validade do CA, estoque e periodicidade de troca |
| RF08 | Registro de entrega: colaborador, data, um ou mais EPIs com quantidade, observação e **assinatura na tela** |
| RF09 | Baixa automática do estoque; bloqueio de entrega de EPI sem estoque ou com CA vencido (NR-6) |
| RF10 | Histórico de entregas com busca e comprovante detalhado (itens, CA, próxima troca e assinatura) |

## Telas

1. **Login**
2. **Criar acesso** (cadastro de usuário)
3. **Painel** (indicadores, trocas previstas e últimas entregas)
4. **Entregas** (lista com busca)
5. **Nova entrega** (formulário com seleção de EPIs e assinatura)
6. **Detalhe da entrega** (comprovante)
7. **Colaboradores** (lista com busca)
8. **Ficha do colaborador** (dados e histórico)
9. **Cadastro/edição de colaborador**
10. **EPIs** (catálogo com estoque e validade do CA)
11. **Cadastro/edição de EPI**

## Requisitos do trabalho (T3)

| Requisito | Onde está |
|-----------|-----------|
| Pelo menos 5 telas (grupo de 3) | 11 telas, listadas acima |
| Componentes de interface gráfica | Formulários, `DropdownButtonFormField`, `SwitchListTile`, `showDatePicker`, `NavigationBar`, `Card`, `FloatingActionButton`, diálogos e uma área de assinatura própria (`CustomPainter`) |
| ListView | `ListView.separated` nas listas de entregas, colaboradores e EPIs; `ListView` nos formulários e no painel |
| Navegação entre telas | `Navigator.push`/`pop` com retorno de resultado e `NavigationBar` com 4 abas |
| Persistência de dados | SQLite (`sqflite`) com 5 tabelas e transação na baixa de estoque; sessão em `shared_preferences` |

## Como rodar

Pré-requisitos: Flutter 3.50+ e Android SDK.

```bash
flutter pub get
flutter run          # com um emulador ou aparelho Android conectado
flutter test         # testes de regra de negócio e banco
flutter build apk    # gera build/app/outputs/flutter-apk/app-release.apk
```

Na primeira execução o banco é criado com dados de exemplo (EPIs com CAs
fictícios e 4 colaboradores). **Acesso de demonstração:** `admin@hc.com` / `hc123456`.

O roteiro da apresentação, com a divisão entre os integrantes, está em
[`docs/ROTEIRO-APRESENTACAO.md`](docs/ROTEIRO-APRESENTACAO.md).

## Estrutura

```
lib/
├── main.dart                 # abre o banco, restaura a sessão e inicia o app
├── app.dart                  # MaterialApp, tema e troca login ↔ área logada
├── theme/hc_theme.dart       # identidade visual da HC
├── core/                     # formatação pt-BR, validação de CPF, hash de senha
├── data/
│   ├── database.dart         # esquema SQLite e dados de exemplo
│   ├── models.dart           # Usuario, Colaborador, Epi, Entrega...
│   └── repositorios.dart     # consultas e regras (estoque, trocas previstas)
├── services/app_services.dart# sessão do usuário e acesso aos repositórios
├── screens/                  # uma tela por arquivo
└── widgets/                  # logo, assinatura, componentes comuns
```

## Modelo de dados

```
usuarios (id, nome, email, senha_hash)
colaboradores (id, nome, cpf, matricula, setor, funcao, ativo)
epis (id, nome, ca, validade_ca, estoque, periodicidade_dias)
entregas (id, colaborador_id → colaboradores, usuario_id → usuarios, data, observacao, assinatura)
entrega_itens (id, entrega_id → entregas, epi_id → epis, quantidade)
```

As senhas são guardadas como hash SHA-256 com salt aleatório, nunca em texto puro.
