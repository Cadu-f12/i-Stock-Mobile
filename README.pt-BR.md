# I-STOCK Mobile

> Aplicativo Flutter para gerenciamento do estoque de pastilhas industriais da DDA Metalúrgica, em Santa Catarina, Brasil.

**🇧🇷 Português** | [🇺🇸 English](README.md)

---

## 📌 Sobre o Projeto

O **I-STOCK Mobile** é o aplicativo móvel complementar ao sistema de gerenciamento de estoque I-Stock. Está sendo desenvolvido com Flutter para facilitar o acesso dos colaboradores às informações do estoque e o registro de movimentações por dispositivos móveis.

O projeto atende ao fluxo de controle das pastilhas industriais utilizadas nos processos de usinagem e fabricação. Seu objetivo é facilitar o acesso às informações do estoque e às operações do dia a dia onde o trabalho acontece.

Este aplicativo está sendo criado em um repositório mobile separado e foi planejado para se integrar à API backend do sistema I-Stock conforme essa integração for definida.

---

## 🎯 Objetivo

Informações precisas sobre o estoque ajudam a evitar a falta de materiais e interrupções na produção. Um aplicativo móvel pode facilitar a consulta do estoque e o registro das movimentações pelos usuários autorizados, sem depender de um computador.

O escopo e os recursos disponíveis serão definidos conforme os requisitos do projeto e a integração com a API forem estabelecidos.

---

## 💡 Recursos Planejados

O aplicativo pretende apoiar tarefas de estoque, como:

* Consultar o estoque e os níveis de pastilhas industriais.
* Registrar entradas e saídas de materiais.
* Consultar o histórico de movimentações.
* Identificar itens que possam precisar de reposição.

Esses recursos representam a direção do projeto; sua disponibilidade depende da implementação e do suporte do backend.

---

## 🏗️ Arquitetura

O aplicativo é desenvolvido com **Flutter** e **Dart**. A comunicação com o backend do I-Stock está planejada para ocorrer por meio de uma API REST.

```text
┌─────────────────────────────┐
│       Aplicativo Mobile     │
│       Flutter + Dart        │
└──────────────┬──────────────┘
               │ HTTP / API REST
               ▼
┌─────────────────────────────┐
│       Backend I-Stock       │
│       Java + Spring Boot    │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│          MySQL              │
└─────────────────────────────┘
```

---

## 🛠️ Tecnologias

* **Flutter** — toolkit multiplataforma para interfaces móveis.
* **Dart** — linguagem de programação da aplicação.
* **API REST** — comunicação planejada com o backend do I-Stock.

---

## 🚀 Como Começar

### Pré-requisitos

Instale o [Flutter SDK](https://docs.flutter.dev/get-started/install) e um ambiente de desenvolvimento compatível com Android ou iOS.

### Executar o aplicativo

```bash
git clone https://github.com/Cadu-f12/i-Stock-Mobile.git
cd i-Stock-Mobile
flutter pub get
flutter run
```

Selecione um dispositivo conectado ou inicie um emulador antes de executar o aplicativo. As configurações de conexão com a API e os requisitos do backend serão documentados quando forem adicionados ao projeto.

---

## 📂 Estrutura do Projeto

```text
i-Stock-Mobile/
├── android/                 # Projeto hospedeiro Android
├── ios/                     # Projeto hospedeiro iOS
├── lib/                     # Código-fonte Dart
├── test/                    # Testes Flutter
├── web/                     # Projeto hospedeiro Web
├── pubspec.yaml             # Metadados e dependências
└── README.md
```

A estrutura poderá crescer conforme os recursos e integrações forem implementados.

---

## 🎓 Contexto do Projeto

O I-STOCK Mobile está relacionado ao projeto de gerenciamento de estoque I-Stock da **DDA Metalúrgica**, em Santa Catarina, Brasil. O sistema original é um projeto acadêmico de desenvolvimento de software no **SENAI/SC**.

---

## 🌐 Documentação

* 🇧🇷 **Português** — `README.pt-BR.md`
* 🇺🇸 **English** — [`README.md`](README.md)
