#  ColetaAgendada — App Mobile (Flutter)

> **Global Solution 2026 • CitizenTech** — Aplicativo mobile que conecta condomínios e comércios geradores de recicláveis limpos a coletores autônomos e cooperativas, com agendamento de lotes, reserva exclusiva de rota e validação da retirada por PIN de 4 dígitos.

---

##  Desenvolvedores

| Felipe Boveri | 555055 |
| Clara de Fonte | 554321 |

---

##  Tema da Global Solution

**CitizenTech — tecnologia para impacto social e ambiental urbano.**

Pequenos comércios e condomínios acumulam diariamente papelão, plástico, latas e vidro limpos. Como a coleta pública tem horários rígidos, o material ocupa espaço ou vai parar na calçada. Do outro lado, coletores caminham quilômetros sem saber onde há material disponível e perdem viagens.

**ODS atendidos (Agenda 2030 da ONU)**
- **ODS 10 — Redução das desigualdades:** renda e previsibilidade de rota para coletores.
- **ODS 11 — Cidades e comunidades sustentáveis:** menos resíduos nas calçadas, logística reversa organizada.
- **ODS 13 — Ação contra a mudança global do clima:** mais reciclagem efetiva e contabilização do CO₂ evitado.

---

##  Descrição da solução

| Perfil | O que faz no app |
| --- | --- |
| **Ponto gerador** (síndico / comerciante) | Agenda um lote informando CNPJ, contato, CEP (endereço preenchido via **ViaCEP**), material, peso e janela de retirada. Recebe **protocolo** e **PIN de 4 dígitos**. |
| **Coletor / cooperativa** | Busca lotes por CEP, local ou material; **reserva** o lote (ele sai do radar dos demais); na retirada digita o **PIN** da portaria e recebe o **certificado de impacto**. |

**Regras de negócio implementadas** (`lib/services/lote_service.dart`)
1. Somente CNPJs cadastrados e **ATIVOS** podem publicar lotes.
2. **Trava logística:** lotes abaixo de **10 kg** são bloqueados.
3. Endereço padronizado pelo **CEP** via API ViaCEP.
4. Todo lote válido recebe status `DISPONIVEL`, protocolo único e PIN aleatório de 4 dígitos.
5. Ciclo de vida: `DISPONIVEL → RESERVADO → COLETADO` (só com PIN correto).
6. Impacto: **CO₂ evitado = peso × 1,5** • **Receita = peso × cotação** (Papelão R$ 0,80 • Plástico R$ 1,50 • Alumínio R$ 6,00 • Vidro R$ 0,40 por kg).
7. Privacidade: o telefone da portaria só é exibido após a reserva.

---

##  Fluxo de telas

```
Splash -> Introdução (só na primeira vez) -> Home
```

Na Home tem uma barra embaixo com 4 abas:

- **Início**: mostra o total reciclado, o CO2 evitado e o ganho estimado.
- **Agendar**: formulário para cadastrar um lote novo. O endereço vem do CEP (ViaCEP). No final aparece o protocolo e o PIN.
- **Lotes & Rotas**: lista dos lotes, com busca e filtro. Clicando em um lote abre a tela de **Detalhes**.
- **ODS & Equipe**: integrantes do grupo e os ODS do projeto.

Na tela de **Detalhes** o coletor pode reservar o lote e depois digitar o PIN. Se o PIN estiver certo, abre a tela do **Certificado** com o impacto da coleta.

| Tela | Descrição |
| --- | --- |
| **Splash** | Logo (`Image.asset`), transição automática; lê o `SharedPreferences` e direciona para Onboarding ou Home. |
| **Onboarding** | 4 páginas com ícone, título e descrição; botões **Voltar/Avançar**, **Pular** e a opção **"Não mostrar novamente"** (salva no `SharedPreferences` somente se marcada). |
| **Início** | Impacto coletivo (kg reciclados, CO₂ evitado, ganho estimado), situação dos lotes, ODS e lotes disponíveis. Puxe para atualizar. |
| **Agendar** | Formulário com máscaras, busca de CEP no **ViaCEP** (estados inicial / carregando / sucesso / erro + tentar novamente), escolha de material e janela, trava de 10 kg com prévia do impacto e diálogo com protocolo + PIN. |
| **Lotes & Rotas** | `ListView` de cards, busca por CEP/local/material, filtros (Todos, Disponíveis, Reservados, Coletados, Favoritos) e favoritar. |
| **Detalhes do Lote** | Recebe o **protocolo** por parâmetro. Endereço via ViaCEP, impacto, reservar / cancelar reserva, validar PIN, favoritar e excluir. |
| **Certificado de Impacto** | Recebe um objeto **`ReciboColeta`** por parâmetro com peso, CO₂ evitado e ganho. |
| **ODS & Equipe** | Equipe, ODS, diferenciais, API utilizada e configurações (rever introdução, restaurar dados). |

---

##  Prints das telas

<img width="1279" height="887" alt="Screenshot 2026-11-10 214156" src="https://github.com/user-attachments/assets/c562f86c-6a25-4ea2-961c-995fbafb789b" />
<img width="1276" height="882" alt="Screenshot 2026-11-10 214222" src="https://github.com/user-attachments/assets/7a43924f-5dea-4403-aa7c-8c739c985b9d" />
<img width="1279" height="887" alt="Screenshot 2026-11-10 214238" src="https://github.com/user-attachments/assets/28100baa-2867-42f9-9e64-96a282e1a75c" />
<img width="1279" height="885" alt="Screenshot 2026-11-10 214345" src="https://github.com/user-attachments/assets/8d79c465-ffee-4bc3-805d-e91ee280c14b" />
<img width="1279" height="886" alt="Screenshot 2026-11-10 214413" src="https://github.com/user-attachments/assets/1f3a031d-6fce-4ff5-8356-9bafed8a3188" />
<img width="1279" height="882" alt="Screenshot 2026-11-10 214437" src="https://github.com/user-attachments/assets/94d728a6-b268-4fcb-a8ed-0fa7f12818d1" />

---

##  API utilizada

**ViaCEP** — API REST pública de consulta de CEP, consumida com o pacote [`http`](https://pub.dev/packages/http).

```
GET https://viacep.com.br/ws/{cep}/json/
```

Exemplo de resposta convertida no model `Endereco` (`lib/models/endereco.dart`):

```json
{
  "cep": "01310-100",
  "logradouro": "Avenida Paulista",
  "complemento": "de 612 a 1510 - lado par",
  "bairro": "Bela Vista",
  "localidade": "São Paulo",
  "uf": "SP"
}
```

Tratamento em `lib/services/viacep_service.dart`:
- CEP inexistente (`{"erro": true}`), formato inválido (HTTP 400), outros status HTTP, timeout de 10 s e falta de conexão viram uma `ViaCepException` com mensagem amigável.
- A interface (`EnderecoViaCepCard`) mostra os estados **inicial**, **carregamento**, **sucesso** e **erro** com botão **"Tentar novamente"**.
- Usada em dois lugares: no formulário de agendamento e na tela de detalhes do lote.

> No projeto completo da Global Solution, os dados de geradores e lotes vêm do back-end Java/Oracle (`/api/geradores`, `/api/lotes`). No app mobile essa camada fica nos **repositories** com persistência local, de modo que trocar para a API Java exige alterar apenas os repositories.

---

##  Arquitetura

Separação em camadas: **interface → serviços (regras de negócio) → repositórios (dados) → models**.

```
lib/
├── main.dart                     # ponto de entrada
├── app.dart                      # MaterialApp, tema e rotas nomeadas (onGenerateRoute)
├── core/
│   ├── routes/app_routes.dart    # nomes das rotas
│   ├── theme/                    # AppColors + AppTheme (Material 3)
│   └── utils/                    # Formatters, máscara de input, ViewState
├── models/                       # Lote, Gerador, Endereco, ReciboColeta, ImpactoResumo,
│                                 # MaterialReciclavel, StatusLote, Ods, OnboardingItem, Integrante
├── repositories/                 # LoteRepository (SharedPreferences/JSON), GeradorRepository
├── services/                     # LoteService (regras), ViaCepService (http), PreferencesService
├── screens/                      # Splash, Onboarding, HomeShell, Início, Agendar, Lotes,
│                                 # LoteDetalhe, Recibo, Sobre (ODS & Equipe)
└── widgets/                      # componentes reutilizáveis
```

| Camada | Responsabilidade |
| --- | --- |
| **models** | Classes imutáveis com `fromJson`/`toJson` e propriedades calculadas (`co2Evitado`, `receitaEstimada`). |
| **repositories** | Acesso aos dados: lotes persistidos em JSON no `SharedPreferences`; geradores homologados. |
| **services** | Regras de negócio (validação de CNPJ ativo, piso de 10 kg, geração de protocolo/PIN, transições de status, cálculo de impacto, filtros), consumo do ViaCEP e preferências. |
| **screens** | Apenas interface e estado da tela com `setState`; chamam os serviços e exibem o resultado. |
| **widgets** | Componentes reutilizados entre telas. |

**Gerenciamento de estado:** `StatefulWidget` + `setState` nas telas que mudam (Splash, Onboarding, HomeShell, Início, Agendar, Lotes, Detalhes); `StatelessWidget` nas telas e componentes somente de exibição (Recibo, ODS & Equipe e todos os widgets).

**Navegação:** rotas nomeadas com `onGenerateRoute`, `pushReplacementNamed` (Splash/Onboarding), `pushNamed` com argumentos (`int protocolo` e `ReciboColeta`), `pop` com retorno e `PopScope` para que o botão voltar do Android retorne à aba Início antes de sair.

**Widgets reutilizáveis** (`lib/widgets/`): `AppLogo`, `SectionCard`, `StatCard`, `StatusBadge`, `LoteCard`, `ImpactoMaterialBox`, `InfoRow`, `PageHeaderBanner`, `AlertBanner`, `EnderecoViaCepCard`, `PinBox`, `OdsTile`/`OdsChip`/`OdsNumero`, `OnboardingPage`, `LoadingView`, `ErrorView`, `EmptyView`.

**Interações implementadas:** abrir detalhes ao tocar no lote • busca por texto • filtros por status • favoritar • reservar / cancelar reserva • validar PIN • excluir com confirmação • mostrar/ocultar PIN • puxar para atualizar • escolher gerador homologado • prévia do impacto em tempo real.
