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

### Configurar a URL da API (`.env`)

O aplicativo lê `ISTOCK_API_BASE_URL` de um arquivo `.env` na raiz do projeto. Crie seu arquivo local a partir do modelo versionado:

```bash
cp .env.example .env
```

Edite o `.env` e informe a URL base que o aplicativo em execução consiga acessar:

```dotenv
ISTOCK_API_BASE_URL=http://10.0.2.2:8080/
```

Escolha o endereço conforme o destino:

* **Emulador Android:** `http://10.0.2.2:8080/` acessa a porta 8080 do computador de desenvolvimento.
* **Simulador iOS ou aplicativo executado no mesmo computador:** use `http://localhost:8080/` quando a API estiver disponível nesse computador.
* **Dispositivo físico:** use o endereço da rede local do computador, por exemplo `http://192.168.1.20:8080/`. O dispositivo e o computador precisam conseguir se comunicar, e a API deve aceitar conexões da rede local.

`localhost` aponta para o próprio dispositivo ou emulador e pode não alcançar uma API executada no computador de desenvolvimento. O aplicativo carrega o `.env` ao iniciar; encerre e execute o app novamente depois de alterar o valor. O `.env` está no `.gitignore`; mantenha esse arquivo local e fora dos commits. A URL é configuração, não um local para senhas ou segredos da API, pois valores incluídos em um aplicativo móvel podem ser inspecionados.

### Executar o aplicativo

```bash
git clone https://github.com/Cadu-f12/i-Stock-Mobile.git
cd i-Stock-Mobile
flutter pub get
flutter run
```

Selecione um dispositivo conectado ou inicie um emulador antes de executar o aplicativo. Confira se a URL base da API no `.env` pode ser acessada por esse destino.

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
