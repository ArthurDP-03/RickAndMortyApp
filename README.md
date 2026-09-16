# RM Guide — Catálogo Interativo Rick and Morty

Projeto Somativo desenvolvido em Flutter para a disciplina de **Desenvolvimento Mobile Híbrido** (BSI - 6° período).

## 👥 Integrantes do Grupo
1. Arthur de Oliveira Carvalho
2. Caio Eduardo Lamoglia
3. João Victor Saboya Ribeiro de Carvalho
4. Matheus De Bortoli Silva

---

## 🚀 Funcionalidades Principais (RF01 - RF10)

- **Catálogo Dinâmico (RF01, RF02, RF08)**: Grade responsiva de episódios da API Rick and Morty com paginação ("Carregar Mais"), busca textual direta e filtros avançados (nome, temporada e data).
- **Detalhes Completos (RF03)**: Exibição dos metadados do episódio (`name`, `air_date`, `episode`, `url`, `created`) e lista de personagens com imagem e status.
- **Favoritos & Assistidos com Provider (RF04, RF05, RF07)**: Gerenciamento reativo de estado global permitindo favoritar e marcar episódios como assistidos/consumidos, com telas dedicadas e ordenação crescente.
- **Persistência Híbrida (RF06)**: Armazenamento local persistente com `shared_preferences` e suporte para Firebase via arquivo `.env`.
- **Autenticação & Perfil (RF07)**: Fluxo obrigatório de login (tema Morty) e cadastro (tema Rick), além de tela de edição de perfil e estatísticas de progresso no multiverso.
- **Feedback Visual & Acessibilidade (RF09, RF10)**: Indicadores de carregamento temáticos, telas amigáveis de erro com retry, suporte a leitores de tela (`Semantics`), alto contraste e design responsivo.

---

## 🛠️ Como Executar o Projeto

1. Instale as dependências:
   ```bash
   flutter pub get
   ```

2. (Opcional) Configure as variáveis de ambiente no arquivo `.env` para Firebase:
   ```env
   API_BASE_URL=https://rickandmortyapi.com/api
   FIREBASE_API_KEY=
   FIREBASE_APP_ID=
   FIREBASE_PROJECT_ID=
   ```

3. Execute o projeto no emulador ou dispositivo:
   ```bash
   flutter run
   ```

4. Para rodar a suíte de testes:
   ```bash
   flutter test
   ```
