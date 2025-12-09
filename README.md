# CheckPills 💊

O **CheckPills** é um aplicativo móvel desenvolvido para auxiliar no gerenciamento e controle da ingestão de medicamentos. Com uma interface intuitiva, o objetivo é garantir que o usuário nunca esqueça seus horários, promovendo a adesão correta ao tratamento.

---

## 📱 Download do Aplicativo

Para testar a versão mais recente do aplicativo em seu dispositivo Android, faça o download do APK através do link abaixo:

👉 **[Baixar CheckPills (APK Atualizado)](https://drive.google.com/drive/folders/1zIOO2twZtHmditmeKGpQDSfTxbg1MGC7?usp=sharing)**

---

## 🚀 Tecnologias Utilizadas

Este projeto foi desenvolvido utilizando as seguintes tecnologias:

* **[React Native](https://reactnative.dev/):** Framework principal para desenvolvimento mobile.
* **[Expo](https://expo.dev/):** Plataforma para facilitar a criação e build do app.
* **JavaScript/TypeScript:** Linguagem de programação.
* **React Navigation:** Para navegação entre telas.

---

## 💻 Pré-requisitos

Antes de começar, certifique-se de ter as seguintes ferramentas instaladas em sua máquina:

* **[Node.js](https://nodejs.org/en/)** (Versão LTS recomendada)
* **[Git](https://git-scm.com/)**
* **[Expo CLI](https://docs.expo.dev/get-started/installation/)** (Instalado globalmente ou via npx)

---

## 🔧 Como Executar o Projeto

Siga o passo a passo abaixo para rodar o projeto localmente em ambiente de desenvolvimento:

### 1. Clone o repositório

Abra o seu terminal e execute o comando:

```bash
git clone [https://github.com/MBritoS19/CheckPills.git](https://github.com/MBritoS19/CheckPills.git)
```

### 2. Acesse a pasta do projeto

```bash
cd CheckPills
```

### 3. Instale as dependências

Execute o comando abaixo para baixar todas as bibliotecas necessárias:

```bash
npm install
# ou, se estiver usando yarn:
yarn install
```

### 4. Execute o aplicativo

Inicie o servidor de desenvolvimento do Expo:

```bash
npx expo start
```

Uma vez iniciado:
* Pressione `a` no terminal para abrir no **Emulador Android**.
* Pressione `i` para abrir no **Simulador iOS** (apenas Mac).
* Ou escaneie o **QR Code** com o aplicativo **Expo Go** no seu celular físico.

---

## 📦 Como Gerar o APK (Build)

Para gerar o arquivo instalável (.apk) para Android, utilizamos o **EAS Build** (Expo Application Services).

### 1. Instale o EAS CLI (se ainda não tiver)

```bash
npm install -g eas-cli
```

### 2. Faça login na sua conta Expo

```bash
eas login
```

### 3. Configure o Build (apenas na primeira vez)

```bash
eas build:configure
```
*Selecione `Android` quando perguntado.*

### 4. Gere o APK

Para gerar um APK instalável (ideal para testes internos e distribuição via Drive):

```bash
eas build -p android --profile preview
```

> **Nota:** O processo pode levar alguns minutos, pois é feito na nuvem. Ao finalizar, o terminal exibirá um link direto para baixar o seu APK.

---

## 🤝 Contribuição

Contribuições são bem-vindas! Se você tiver sugestões de melhorias ou encontrar bugs, sinta-se à vontade para abrir uma *issue* ou enviar um *pull request*.

---

## 👤 Autores

Desenvolvido por:
**[MBritoS19](https://github.com/MBritoS19)**.
**[luigi10082002](https://github.com/luigi10082002)**.
**[LeonardoYur](https://github.com/LeonardoYur)**.

Entre em contato!
