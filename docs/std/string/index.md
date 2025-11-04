# String - Testo UTF-8 in Rust

!!! info "Riferimento originale"
    📖 [Documentazione originale](https://doc.rust-lang.org/std/string/)
    🔄 Ultimo aggiornamento: Novembre 2025
    📝 Versione Rust: 1.90+

Benvenuto nella sezione dedicata alla gestione del testo in Rust!
Questa sezione copre `String` e `&str`, due tipi fondamentali per lavorare
con il testo.

## Panoramica

Rust offre due tipi principali per gestire testo UTF-8:

### String

**`String`** è una stringa allocata sullo heap, dinamica e di proprietà. Può crescere, ridursi ed essere modificata.

```rust
let mut s = String::from("Ciao");
s.push_str(" mondo!");
assert_eq!(s, "Ciao mondo!");
```

**Quando usarla:**

- Quando devi possedere i dati testuali
- Quando la stringa deve essere modificata
- Quando la dimensione è dinamica

[**Documentazione completa di String →**](string.md)

### &str (String Slice)

**`&str`** è un riferimento immutabile a una sequenza di caratteri UTF-8. È un "prestito" di dati testuali.

```rust
let s: &str = "Ciao mondo!";
// s è immutabile e non possiede i dati
```

**Quando usarla:**

- Come parametro nelle funzioni (più flessibile)
- Per letterali stringa (`"testo"`)
- Quando serve solo leggere il testo

!!! tip "Best Practice"
    Nelle funzioni, preferisci `&str` come tipo di parametro invece di
    `String`. Rust converte automaticamente `String` in `&str` quando
    necessario grazie a `Deref`, rendendo le tue funzioni più flessibili.

## Confronto Rapido

| Caratteristica | `String` | `&str` |
|----------------|----------|--------|
| **Ownership** | Possiede i dati | Riferimento preso in prestito |
| **Allocazione** | Heap | Stack / binario / heap |
| **Mutabilità** | Modificabile (se `mut`) | Sempre immutabile |
| **Dimensione** | Dinamica | Fissa |
| **Uso tipico** | Costruire/modificare testo | Leggere/passare testo |

```rust
// String - possiede e può modificare
let mut owned = String::from("Ciao");
owned.push_str(" mondo");

// &str - solo lettura
let borrowed: &str = "Ciao mondo";

// Conversione automatica String → &str
fn stampa(testo: &str) {
    println!("{}", testo);
}

stampa(&owned);    // String convertito in &str
stampa(borrowed);  // Già un &str
```

## Caratteristiche Chiave

### UTF-8 Garantito

Ogni `String` e `&str` contiene **sempre** UTF-8 valido. Rust garantisce questa invariante a compile-time.

```rust
// ✅ UTF-8 valido
let emoji = String::from("Rust 🦀");
let cirillico = String::from("Здравствуйте");

// ❌ Non compila - non puoi creare UTF-8 invalido
// (senza usare metodi unsafe)
```

### Nessun Indice Diretto

A causa di UTF-8, non puoi accedere ai caratteri per indice:

```rust
let s = String::from("Ciao");
// let c = s[0]; // ❌ ERRORE! Non compila
let c = s.chars().nth(0).unwrap(); // ✅ OK
```

**Perché?** I caratteri UTF-8 possono occupare 1-4 byte, quindi un indice
numerico non identifica necessariamente un carattere completo.

## Operazioni Comuni

### Creazione

```rust
// String vuota
let s = String::new();

// Da un letterale
let s = String::from("Ciao");
let s = "Ciao".to_string();

// Con capacità predefinita
let s = String::with_capacity(100);

// Con formattazione
let s = format!("Numero: {}", 42);
```

### Modifica

```rust
let mut s = String::from("Ciao");

s.push(' ');              // Aggiunge carattere
s.push_str("mondo");      // Aggiunge stringa
s.insert(0, '!');         // Inserisce alla posizione
s.remove(0);              // Rimuove alla posizione
s.truncate(4);            // Tronca a 4 byte
s.clear();                // Svuota
```

### Iterazione

```rust
let s = String::from("Rust 🦀");

// Sui caratteri Unicode
for c in s.chars() {
    println!("{}", c);
}

// Sui byte
for b in s.bytes() {
    println!("{}", b);
}

// Con indici
for (i, c) in s.char_indices() {
    println!("'{}' @ byte {}", c, i);
}
```

### Ricerca e Pattern

```rust
let s = String::from("Rust è fantastico");

s.contains("Rust");           // true
s.starts_with("Rust");        // true
s.ends_with("fantastico");    // true
s.find("è");                  // Some(5)
s.replace("Rust", "Go");      // "Go è fantastico"
```

### Splitting

```rust
let s = String::from("uno,due,tre");

for parte in s.split(',') {
    println!("{}", parte);
}

let parti: Vec<&str> = s.split(',').collect();
```

## Conversioni

```rust
// String ↔ &str
let s = String::from("test");
let r: &str = &s;              // String → &str
let s2 = r.to_string();        // &str → String

// Da numeri
let n = 42;
let s = n.to_string();         // "42"

// A numeri
let s = String::from("42");
let n: i32 = s.parse().unwrap(); // 42

// Da/a Vec<u8>
let v = vec![72, 101, 108, 108, 111];
let s = String::from_utf8(v).unwrap();
let v2 = s.into_bytes();
```

## Risorse

### Documentazione Dettagliata

- [**String**](string.md) - Documentazione completa di String
- [**str**](https://doc.rust-lang.org/std/primitive.str.html) - Documentazione ufficiale di &str

### Documentazione Ufficiale (Inglese)

- [String - std](https://doc.rust-lang.org/std/string/struct.String.html)
- [str - Primitive](https://doc.rust-lang.org/std/primitive.str.html)
- [The Book - Chapter 8.2](https://doc.rust-lang.org/book/ch08-02-strings.html)
- [Rust by Example - Strings](https://doc.rust-lang.org/rust-by-example/std/str.html)

### Altre Risorse

- [OsString](https://doc.rust-lang.org/std/ffi/struct.OsString.html) - Per path di sistema (non UTF-8)
- [CString](https://doc.rust-lang.org/std/ffi/struct.CString.html) - Per interop con C
- [PathBuf](https://doc.rust-lang.org/std/path/struct.PathBuf.html) - Per percorsi filesystem

---

!!! question "Hai trovato errori o imprecisioni?"
    Aiutaci a migliorare questa traduzione!
    [Apri una issue](https://github.com/rust-ita/rust-docs-it/issues)
    o proponi una modifica.
