# Roteiro de apresentação — EPI HC

Tempo sugerido: **15 minutos** (cerca de 5 min por integrante) + perguntas.
Cada integrante apresenta **5 itens**. A demonstração segue um fluxo contínuo no
mesmo aparelho: quem fala também opera o app, e o próximo integrante continua de
onde o anterior parou.

| Integrante | Tema | Itens |
|---|---|---|
| **Integrante 1** | Contexto, acesso e painel | 1. Abertura · 2. Login · 3. Criar acesso · 4. Painel · 5. Identidade visual e sessão |
| **Integrante 2** | Cadastros | 6. Lista de EPIs · 7. Cadastro de EPI · 8. Lista de colaboradores · 9. Cadastro de colaborador · 10. ListView e navegação |
| **Integrante 3** | Entregas | 11. Ficha do colaborador · 12. Nova entrega · 13. Comprovante da entrega · 14. Histórico de entregas · 15. Persistência (SQLite) |
| Todos | Encerramento | Requisitos atendidos e perguntas |

---

## Antes de apresentar (checklist)

- [ ] Desinstalar e reinstalar o app (ou limpar os dados dele) para começar com o
      banco zerado e só os dados de exemplo.
- [ ] Rodar `flutter run` no celular/emulador e testar o login uma vez. **Depois
      sair da conta** (menu do avatar → Sair) para começar na tela de login.
- [ ] Celular carregado, brilho no máximo, notificações em modo "não perturbe".
- [ ] Espelhamento da tela (scrcpy, Vysor ou o próprio emulador no projetor).
- [ ] VS Code aberto no projeto, caso o professor peça para ver o código.
- [ ] Ensaiar a passagem entre integrantes (quem segura o celular em cada parte).

Dados que serão digitados durante a demonstração:

| Onde | Valor |
|---|---|
| Login de demonstração | `admin@hc.com` / `hc123456` |
| Novo EPI | Nome: `Luva de raspa` · CA: `12345` · Validade: qualquer data em 2028 · Estoque: `20` · Troca: `1 mês` |
| Novo colaborador | Nome: `Pedro Henrique Lopes` · CPF: `471.263.859-19` · Matrícula: `1200` · Setor: `Produção` · Função: `Montador` |

---

## Integrante 1 — Contexto, acesso e painel (≈5 min)

### 1. Abertura
> "Nosso app se chama **EPI HC**. É um aplicativo Android feito em **Flutter**
> para controlar a entrega de Equipamentos de Proteção Individual aos
> colaboradores de uma empresa. Ele foi pensado como uma extensão da **HC
> Assessoria de Segurança do Trabalho**, que presta serviços de segurança e
> medicina do trabalho.
>
> O problema que ele resolve: a NR-6 obriga a empresa a entregar EPI gratuitamente,
> registrar essa entrega e ter a assinatura do colaborador. Muitas empresas ainda
> fazem isso em ficha de papel. Com o app, o técnico registra a entrega no
> celular, o colaborador assina na tela e o estoque é atualizado na hora."

### 2. Tela de login
**Na tela:** mostrar a tela de login.
- Digitar `admin@hc.com` com uma senha errada e tocar em **ENTRAR** → aparece "E-mail ou senha incorretos".
- **Ainda não entrar:** tocar em **"Não tem conta? Criar acesso"** e seguir para o item 3.

> "O acesso é por e-mail e senha. O formulário valida os campos antes de enviar,
> e a senha não fica guardada em texto puro: salvamos só um hash SHA-256 com salt."

### 3. Criar acesso
**Na tela:** abrir a tela de cadastro e mostrar as validações (deixar campos
vazios e tocar em **CRIAR E ENTRAR**; digitar senhas diferentes na confirmação).

> "Novos técnicos podem criar o próprio acesso. O app impede e-mail repetido e
> confere se as duas senhas são iguais."

Voltar (seta do topo) e fazer o login com `admin@hc.com` / `hc123456`.

### 4. Painel
**Na tela:** o painel logo após o login.

> "Esta é a tela inicial. Os quatro cartões mostram as **entregas do mês**, os
> **colaboradores ativos**, os **EPIs com estoque baixo** e os **CAs vencidos**.
> Os cartões são clicáveis e levam para a aba correspondente.
>
> Abaixo temos as **trocas previstas**: o app calcula, pela última entrega e pela
> periodicidade de cada EPI, quando o colaborador precisa trocar o equipamento.
> Como ainda não fizemos nenhuma entrega, está vazio — vamos ver isso funcionar
> no final."

Apontar que já existe **1 CA vencido** (respirador PFF2) e **1 EPI com estoque baixo** (luva nitrílica).

### 5. Identidade visual e sessão
> "A identidade visual veio do site da HC: a logo oficial, o azul da marca sobre
> tons neutros e as mesmas fontes do site — Archivo nos títulos, Oswald nos
> rótulos em caixa-alta, como placas de sinalização, e Public Sans no texto. As
> fontes vão dentro do app, então funciona sem internet.
>
> Outro detalhe: a sessão fica salva com `shared_preferences`. Se eu fechar e
> abrir o app, continuo logado, até tocar em **Sair** no menu do avatar."

**Passagem:** "Agora o [Integrante 2] vai mostrar os cadastros que alimentam o sistema."

---

## Integrante 2 — Cadastros (≈5 min)

### 6. Lista de EPIs
**Na tela:** tocar na aba **EPIs**.

> "Aqui fica o catálogo de EPIs. Cada item mostra o número do **CA** — o
> Certificado de Aprovação do Ministério do Trabalho —, a validade do CA, a
> periodicidade de troca e o estoque. O número do estoque muda de cor: verde
> normal, amarelo quando está baixo e vermelho quando zera. O respirador está
> marcado com **CA vencido**."

Digitar `luva` na busca para mostrar o filtro e depois apagar.

### 7. Cadastro de EPI
**Na tela:** tocar no **+** e cadastrar a **Luva de raspa** (dados do checklist).
- Mostrar o seletor de data em português na validade do CA.
- Mostrar a lista de periodicidade de troca.
- Salvar → a lista recarrega com o novo EPI.

> "Tocando num EPI dá para editar ou excluir. O app só deixa excluir EPI que
> nunca foi entregue, para não perder o histórico."

### 8. Lista de colaboradores
**Na tela:** aba **Colaboradores**.

> "A lista mostra nome, função, setor e matrícula, com as iniciais no avatar. A
> busca funciona por nome, matrícula ou setor."

Buscar por `Produção` para mostrar o filtro por setor e depois apagar.

### 9. Cadastro de colaborador
**Na tela:** tocar no botão de adicionar e cadastrar o **Pedro Henrique Lopes**.
- Antes, digitar um CPF inválido (ex.: `111.111.111-11`) para mostrar o erro.
- Corrigir para `471.263.859-19` e salvar.

> "O CPF é validado pelos dígitos verificadores e não pode se repetir. Também
> dá para inativar um colaborador que saiu da empresa: ele continua no histórico,
> mas não aparece mais para novas entregas."

### 10. ListView e navegação (requisito técnico)
> "Todas essas listas usam **ListView** — mais precisamente `ListView.separated`,
> que só constrói os itens visíveis na tela. A navegação usa a **NavigationBar**
> com quatro abas e o **Navigator** para abrir as telas de cadastro. Quando um
> cadastro é salvo, a tela devolve um resultado e a lista anterior recarrega
> sozinha — foi o que aconteceu agora com o EPI e o colaborador."

**Passagem:** "Com EPIs e colaboradores cadastrados, o [Integrante 3] vai mostrar a função principal: a entrega."

---

## Integrante 3 — Entregas (≈5 min)

### 11. Ficha do colaborador
**Na tela:** na lista de colaboradores, tocar no **Pedro Henrique Lopes**.

> "Esta é a ficha de EPI do colaborador, que substitui a ficha de papel: dados
> dele e o histórico de tudo o que já recebeu. Por enquanto está vazio. Daqui
> mesmo eu posso tocar em **ENTREGAR EPI**, e o colaborador já vem selecionado."

Tocar em **ENTREGAR EPI**.

### 12. Nova entrega
**Na tela:** formulário de entrega com o Pedro já selecionado.
- Mostrar que o **Respirador PFF2** aparece bloqueado com a etiqueta **CA vencido**.
- Adicionar **1 Luva de raspa**, **1 Luva nitrílica** e **1 Capacete**.
- Na luva nitrílica, tentar aumentar além de 4 → o botão **+** trava no estoque.
- Escrever uma observação: `Primeira entrega - admissão`.
- **Pedir para alguém da turma (ou o professor) assinar na tela.**
- Tocar em **REGISTRAR ENTREGA**.

> "O formulário tem três passos: colaborador e data, os EPIs com a quantidade, e
> a assinatura. Seguindo a NR-6, o app **não deixa entregar EPI com CA vencido**,
> e a quantidade não passa do estoque. A assinatura é desenhada com o dedo — fizemos
> esse componente do zero com `CustomPainter` — e é salva como imagem PNG junto com
> a entrega."

### 13. Comprovante da entrega
**Na tela:** de volta à ficha, tocar na entrega que acabou de aparecer.

> "Este é o comprovante: colaborador, data e hora, quem entregou, cada EPI com
> o CA e a **data da próxima troca**, e a assinatura do colaborador com o termo
> de recebimento da NR-6."

### 14. Histórico de entregas
**Na tela:** voltar, ir à aba **Entregas** e depois ao **Painel**.

> "Na aba Entregas fica o histórico geral, com busca por colaborador. E no painel
> agora aparece **1 entrega no mês**, a entrega nas **últimas entregas** e, em
> **trocas previstas**, a luva nitrílica do Pedro — ela tem troca a cada 15 dias,
> então já entra no alerta."

Mostrar também na aba **EPIs** que o estoque da luva nitrílica caiu de 4 para 3.

### 15. Persistência de dados (requisito técnico)
> "Tudo fica salvo num banco **SQLite** no próprio aparelho, usando o pacote
> `sqflite`, então funciona sem internet. São cinco tabelas: usuários,
> colaboradores, EPIs, entregas e itens da entrega. O registro da entrega e a baixa
> de estoque acontecem numa **transação**: se um item não tiver saldo, nada é
> gravado. Essas regras têm testes automatizados, que rodam com `flutter test`."

**Passagem:** "Para fechar, voltamos para o resumo."

---

## Encerramento — todos (≈1 min)

Cada integrante fala uma linha:

- **Integrante 1:** "Atendemos o requisito de telas com folga: são **11 telas**, e o mínimo para grupo de três era 5."
- **Integrante 2:** "Usamos componentes de interface do Material, **ListView** nas listas e navegação com abas e `Navigator`."
- **Integrante 3:** "E a persistência é em **SQLite**, com a sessão do usuário em `shared_preferences`. Obrigado! Alguma pergunta?"

---

## Perguntas que o professor pode fazer

| Pergunta | Resposta curta | Quem responde |
|---|---|---|
| Por que Flutter? | Pedido da disciplina; um código só em Dart, com componentes Material prontos e boa performance no Android. | Integrante 1 |
| Como a senha é guardada? | Hash SHA-256 com um salt aleatório por usuário (`lib/core/senha.dart`). Nunca em texto puro. | Integrante 1 |
| Como o app sabe que o usuário continua logado? | Guarda o id do usuário em `shared_preferences` e restaura ao abrir (`lib/services/app_services.dart`). | Integrante 1 |
| Por que `ListView.separated` e não `Column`? | Ele constrói só os itens visíveis, então a lista continua leve com muitos registros. | Integrante 2 |
| Como a lista atualiza depois de salvar? | A tela de cadastro faz `Navigator.pop(true)`; quem abriu recebe o `true` e recarrega (`lib/screens/home_screen.dart`). | Integrante 2 |
| Como o CPF é validado? | Cálculo dos dois dígitos verificadores (`lib/core/formatos.dart`), e o banco tem `UNIQUE` no CPF. | Integrante 2 |
| E se faltar estoque no meio da entrega? | Tudo roda em uma transação (`db.transaction`); se um item falha, nada é gravado (`lib/data/repositorios.dart`). | Integrante 3 |
| Como a assinatura é salva? | Os traços são desenhados com `CustomPainter`, convertidos em PNG e gravados como BLOB na tabela `entregas`. | Integrante 3 |
| Como são calculadas as trocas previstas? | Para cada colaborador e EPI, pega a última entrega e soma a periodicidade; mostra as vencidas e as que vencem em até 15 dias. | Integrante 3 |
| Funciona sem internet? | Sim: banco local, fontes e logo vão dentro do app. | Qualquer um |

## Onde está cada parte no código

| Parte | Arquivo |
|---|---|
| Tema e identidade visual | `lib/theme/hc_theme.dart` |
| Login / criar acesso | `lib/screens/login_screen.dart`, `lib/screens/cadastro_usuario_screen.dart` |
| Painel | `lib/screens/painel_screen.dart` |
| Abas e navegação | `lib/screens/home_screen.dart` |
| EPIs | `lib/screens/epis_screen.dart`, `lib/screens/epi_form_screen.dart` |
| Colaboradores | `lib/screens/colaboradores_screen.dart`, `lib/screens/colaborador_form_screen.dart`, `lib/screens/colaborador_detalhe_screen.dart` |
| Entregas | `lib/screens/entrega_form_screen.dart`, `lib/screens/entrega_detalhe_screen.dart`, `lib/screens/entregas_screen.dart` |
| Assinatura | `lib/widgets/assinatura_pad.dart` |
| Banco e regras | `lib/data/database.dart`, `lib/data/repositorios.dart` |
| Testes | `test/app_test.dart`, `test/login_test.dart` |
