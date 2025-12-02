# Rust Standard Library

!!! info "Riferimento originale"
    📖 [Documentazione originale](https://doc.rust-lang.org/std/)
    🔄 Traduzione in corso
    📝 Versione Rust: 1.90+

La **Standard Library** di Rust è la libreria fornita con ogni installazione di Rust. Offre i tipi fondamentali, le macro essenziali e le funzionalità più comuni per scrivere programmi Rust.

---

## 📚 Sezioni Disponibili

### ✅ Completate

- **[Tipi Primitivi](primitives.md)** - I 18 tipi fondamentali di Rust
  - Tipi numerici (interi e floating-point)
  - Tipi testuali (char, str) e booleani
  - Tipi composti (array, slice, tuple)
  - Puntatori e riferimenti

- **[Collections](collections/vec.md)**
  - **[Vec\<T\>](collections/vec.md)** - Array dinamico ridimensionabile
  - **[HashMap\<K,V\>](collections/hashmap.md)** - Mappe chiave-valore
  - **[HashSet\<T\>](collections/hashset.md)** - Insiemi di valori unici

- **[Stringhe](string/string.md)**
  - **[String](string/string.md)** - Stringhe UTF-8 heap-allocated

- **[Iterators](iterators/index.md)** - Pattern e trait degli iteratori

### 📅 Pianificate

- **Option\<T\>** e **Result\<T, E\>** - Gestione valori opzionali ed errori
- **I/O** - Input/output e gestione file
- Smart Pointers - Box, Rc, Arc, Cell, RefCell
- Concurrency - Thread, canali, sincronizzazione
- Async - Programmazione asincrona

---

## 🔗 Documentazione Originale

Per le sezioni non ancora tradotte, consulta la [documentazione ufficiale in inglese](https://doc.rust-lang.org/std/):

- [Standard Library completa (EN)](https://doc.rust-lang.org/std/)
- [Module Index (EN)](https://doc.rust-lang.org/std/#modules)
- [Primitive Types (EN)](https://doc.rust-lang.org/std/#primitives)
- [Macro Index (EN)](https://doc.rust-lang.org/std/#macros)

---

## 🤝 Vuoi Contribuire?

Vuoi aiutarci a tradurre una sezione della Standard Library?

1. Controlla le [issue aperte](https://github.com/rust-ita/rust-docs-it/issues) con label `traduzione`
2. Leggi la [Guida al Contributo](../CONTRIBUTING.md)
3. Scegli una sezione dalla roadmap
4. Apri una PR!

[**Inizia a contribuire →**](../CONTRIBUTING.md){ .md-button .md-button--primary }

---

## 📖 Struttura della Standard Library

La Standard Library è organizzata in moduli:

### Core Types

- **Primitive types** ✅ - bool, char, i32, str, array, slice, etc.
- **std::option** 📅 - Option\<T\> per valori opzionali
- **std::result** 📅 - Result\<T, E\> per gestione errori

### Collections

- **std::vec** ✅ - Vec\<T\> array dinamici
- **std::collections** 📅 - HashMap, HashSet, BTreeMap, etc.
- **std::string** 📅 - String tipo heap-allocated

### Utility Types

- **std::boxed** - Box\<T\> smart pointer heap
- **std::rc** - Rc\<T\> reference counting
- **std::cell** - Cell e RefCell per interior mutability

### I/O e File System

- **std::io** 📅 - Trait e funzioni I/O
- **std::fs** 📅 - Operazioni filesystem
- **std::path** - Gestione path

### Concurrency

- **std::thread** - Thread nativo
- **std::sync** - Primitive di sincronizzazione
- **std::sync::mpsc** - Canali multi-producer single-consumer

### System

- **std::env** - Variabili ambiente e argomenti
- **std::process** - Gestione processi
- **std::time** - Misurazione tempo

---

## 💡 Suggerimenti per l'Apprendimento

### Per Principianti

1. Inizia con **[Tipi Primitivi](primitives.md)** - Fondamenti del linguaggio
2. Impara **[Vec\<T\>](collections/vec.md)** - Collection più comune
3. Studia **Option e Result** (EN) - Gestione errori idiomatica Rust
4. Esplora **String e &str** (EN) - Manipolazione testo

### Per Utenti Intermedi

- **Collections avanzate** - HashMap, HashSet, BTreeMap
- **Smart Pointers** - Box, Rc, Arc, Cow
- **Iterators** - Programmazione funzionale
- **Error Handling** - Pattern avanzati con Result

### Per Utenti Avanzati

- **Unsafe Rust** - Quando e come usare unsafe
- **FFI** - Interoperabilità con C
- **Async/Await** - Programmazione asincrona
- **Macro** - Metaprogrammazione

---

!!! tip "Documentazione sempre aggiornata"
    La documentazione Rust è sempre accessibile localmente con:
    ```bash
    rustup doc --std
    ```
    Questo apre la documentazione della standard library nel browser, corrispondente alla tua versione di Rust installata.

---

**Ultima revisione**: Ottobre 2025
**Versione Rust**: 1.90+

*Documentazione originale © The Rust Project Developers | Traduzione © Rust Italia Community*
