# Development Setup

Questa cartella contiene gli script e le configurazioni per impostare l'ambiente di sviluppo del progetto rust-docs-it.

## File

- **setup-dev.sh** - Script di setup per Linux/macOS
- **setup-dev.bat** - Script di setup per Windows
- **.pre-commit-config.yaml** - Configurazione pre-commit hooks
- **.markdownlint.json** - Regole di linting per Markdown

## Quick Start

### Linux / macOS

```bash
# Dalla root del progetto
bash dev-setup/setup-dev.sh
```

### Windows

```cmd
# Dalla root del progetto
dev-setup\setup-dev.bat
```

## Cosa fa lo script

1. Verifica che Python 3 sia installato
2. Crea un ambiente virtuale Python (`venv/`)
3. Installa le dipendenze da `requirements.txt`
4. Installa pre-commit hooks
5. Verifica disponibilità markdownlint (richiede Node.js >= 20)

## Configurazioni

### Pre-commit Hooks

I pre-commit hooks vengono eseguiti automaticamente prima di ogni commit per:

- Rimuovere spazi trailing
- Aggiungere newline finale ai file
- Validare sintassi YAML
- Controllare file grandi (>1MB)
- Verificare conflitti di merge
- Formattare codice Python con Black
- Lintare file Markdown con markdownlint
- Controllare typo comuni con codespell

**Eseguire manualmente tutti gli hook:**

```bash
pre-commit run --all-files
```

**Saltare gli hook (sconsigliato):**

```bash
git commit --no-verify
```

### Markdownlint

Regole di linting per file Markdown:

- Lunghezza linea: 120 caratteri (esclusi code block e tabelle)
- Stile heading: ATX (`#`, `##`, ecc.)
- Stile liste: dash (`-`)
- Indentazione liste: 2 spazi
- Code block: fenced (` ``` `)
- Enfasi: asterisco (`*`, `**`)

**Configurazione completa:** `.markdownlint.json`

### Disabilitare regole specifiche

Per disabilitare una regola in un file specifico, aggiungi un commento HTML:

```markdown
<!-- markdownlint-disable MD013 -->
Questa linea può essere molto lunga senza generare warning
<!-- markdownlint-enable MD013 -->
```

## Requisiti

### Obbligatori

- Python 3.7+
- pip

### Opzionali

- Node.js + npm (per markdownlint-cli)
- Git (per pre-commit hooks)

## Troubleshooting

### "pre-commit: command not found"

Assicurati di aver attivato l'ambiente virtuale:

```bash
# Linux/macOS
source venv/bin/activate

# Windows
venv\Scripts\activate.bat
```

### Markdownlint non disponibile

Se npm non è disponibile, markdownlint non funzionerà. Gli hook funzioneranno comunque, ma il linting markdown sarà saltato.

Soluzione: Installa [Node.js](https://nodejs.org/) >= 20 e usa `npx markdownlint-cli '**/*.md'`

### Errori di permessi (Linux/macOS)

```bash
chmod +x dev-setup/setup-dev.sh
bash dev-setup/setup-dev.sh
```

## Struttura File Generati

Dopo l'esecuzione, nella root del progetto troverai:

```
rust-docs-it/
├── venv/                          # Ambiente virtuale Python
├── .pre-commit-config.yaml        # Config pre-commit (copiato)
├── .markdownlint.json             # Config markdownlint (copiato)
└── .git/hooks/pre-commit          # Hook installato
```

## Best Practices

1. **Esegui sempre lo script dopo aver clonato il repo**
2. **Attiva l'ambiente virtuale prima di lavorare**
3. **Lascia che i pre-commit hook facciano il loro lavoro**
4. **Testa localmente con `mkdocs serve` prima di committare**
5. **Esegui `pre-commit run --all-files` periodicamente**

## Aggiornare le Configurazioni

Le configurazioni canoniche sono in `dev-setup/`. Se modifichi quelle nella root, ricorda di aggiornarle anche qui.

Per propagare modifiche:

```bash
# Copia modifiche dalla root a dev-setup
cp .markdownlint.json dev-setup/
cp .pre-commit-config.yaml dev-setup/
```

## Contribuire

Se migliori questi script o configurazioni, assicurati di:

1. Testare su entrambe le piattaforme (Windows e Linux/macOS)
2. Documentare le modifiche in questo README
3. Aggiornare CONTRIBUTING.md se necessario
