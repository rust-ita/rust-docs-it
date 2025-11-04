# String

!!! info "Riferimento originale"
    📖 [Documentazione originale](https://doc.rust-lang.org/std/string/struct.String.html)
    🔄 Ultimo aggiornamento: Novembre 2025
    📝 Versione Rust: 1.90+

Una stringa UTF-8 allocata sullo heap, dinamica e ridimensionabile.

## Panoramica

Il tipo `String` è la struttura dati principale di Rust per gestire testo
modificabile e di proprietà. A differenza di `&str` (string slice), che è un
riferimento preso in prestito a una sequenza di caratteri UTF-8, `String`
possiede i propri dati e può crescere o ridursi dinamicamente.

```rust
let mut s = String::new();
s.push_str("Ciao");
s.push(' ');
s.push_str("mondo!");

assert_eq!(s, "Ciao mondo!");
```

## String vs &str

Una delle distinzioni più importanti in Rust riguarda `String` e `&str`:

| Caratteristica | `String` | `&str` |
|----------------|----------|--------|
| **Ownership** | Possiede i dati | Riferimento preso in prestito |
| **Mutabilità** | Modificabile se dichiarata `mut` | Immutabile |
| **Allocazione** | Heap | Stack (o incorporata nel binario) |
| **Dimensione** | Dinamica (può crescere) | Fissa |
| **Utilizzo** | Quando serve modificare il testo | Per passare testo in lettura |

```rust
// String - possiede i dati
let s1 = String::from("proprietà");

// &str - riferimento
let s2: &str = "prestito";

// String può essere convertito in &str automaticamente
fn stampa_testo(testo: &str) {
    println!("{}", testo);
}

stampa_testo(&s1); // String convertito in &str
stampa_testo(s2);  // Già un &str
```

!!! tip "Quale usare?"
    - Usa **`&str`** come parametro nelle funzioni (più flessibile)
    - Usa **`String`** quando devi possedere o modificare il testo
    - Rust converte automaticamente `String` in `&str` grazie a `Deref`

## Struttura in Memoria

Un `String` è composto da tre parti:

1. **Puntatore**: indirizzo dei dati sullo heap
2. **Lunghezza**: numero di byte attualmente utilizzati
3. **Capacità**: numero di byte allocati

```rust
let mut s = String::with_capacity(10);
println!("Lunghezza: {}, Capacità: {}", s.len(), s.capacity());
// Output: Lunghezza: 0, Capacità: 10

s.push_str("ciao");
println!("Lunghezza: {}, Capacità: {}", s.len(), s.capacity());
// Output: Lunghezza: 4, Capacità: 10
```

!!! warning "Lunghezza in Byte"
    `len()` restituisce il numero di **byte**, non il numero di caratteri!
    Con UTF-8, un carattere può occupare da 1 a 4 byte.

## Creazione di una String

### Usando String::new()

```rust
let s: String = String::new();
```

Crea una stringa vuota senza allocazione iniziale. L'annotazione di tipo è
necessaria perché Rust non può inferire il tipo da una stringa vuota.

### Usando String::from() o to_string()

```rust
let s1 = String::from("Ciao mondo");
let s2 = "Ciao mondo".to_string();

assert_eq!(s1, s2);
```

Entrambi i metodi creano una `String` da un `&str`.

### Usando la macro format

```rust
let nome = "Alice";
let età = 30;
let s = format!("Mi chiamo {} e ho {} anni", nome, età);

assert_eq!(s, "Mi chiamo Alice e ho 30 anni");
```

### Con capacità predefinita

```rust
let mut s = String::with_capacity(100);
```

Preallocare la capacità evita riallocazioni multiple quando aggiungi testo, migliorando le prestazioni.

!!! tip "Quando usare with_capacity"
    Se sai approssimativamente quanto testo conterrà la stringa,
    `with_capacity` può migliorare significativamente le prestazioni
    evitando riallocazioni ripetute.

## Modificare una String

### Aggiungere testo

```rust
let mut s = String::from("Ciao");

// Aggiunge un carattere
s.push('!');

// Aggiunge una stringa
s.push_str(" Come va?");

assert_eq!(s, "Ciao! Come va?");
```

### Concatenazione

```rust
// Usando l'operatore +
let s1 = String::from("Hello, ");
let s2 = String::from("world!");
let s3 = s1 + &s2; // s1 viene mosso, s2 viene preso in prestito

// Usando format! (non sposta i valori)
let s1 = String::from("tic");
let s2 = String::from("tac");
let s3 = String::from("toe");
let s = format!("{}-{}-{}", s1, s2, s3);
```

!!! warning "L'operatore + sposta il primo operando"
    Con `s1 + &s2`, `s1` viene **spostato** e non può più essere usato.
    Se vuoi mantenere entrambe le stringhe, usa `format!` o clona `s1`.

### Inserire e rimuovere

```rust
let mut s = String::from("Ciao mondo");

// Inserisce un carattere alla posizione 4 (in byte)
s.insert(4, ',');
assert_eq!(s, "Ciao, mondo");

// Inserisce una stringa alla posizione 11
s.insert_str(11, " bello");
assert_eq!(s, "Ciao, mondo bello");

// Rimuove un carattere alla posizione 4
s.remove(4);
assert_eq!(s, "Ciao mondo bello");
```

!!! danger "Attenzione agli indici"
    Gli indici in `insert` e `remove` sono **posizioni in byte**, non in
    caratteri. Inserire o rimuovere nel mezzo di un carattere multi-byte
    causa panic!

### Troncare e cancellare

```rust
let mut s = String::from("Ciao mondo");

// Tronca a 4 byte
s.truncate(4);
assert_eq!(s, "Ciao");

// Cancella tutto
s.clear();
assert_eq!(s, "");
```

## UTF-8 e Caratteri

Rust garantisce che ogni `String` contenga UTF-8 valido. Questo ha importanti conseguenze:

### Non puoi indicizzare direttamente

```rust
let s = String::from("Ciao");
// let c = s[0]; // ❌ ERRORE! Non compila
```

Perché? In UTF-8, i caratteri possono occupare 1-4 byte. L'indice `0` non identifica necessariamente un carattere completo.

### Iterare sui caratteri

```rust
let s = String::from("Здравствуйте"); // Russo: "Ciao"

// Itera sui caratteri Unicode
for c in s.chars() {
    print!("{} ", c);
}
println!();
// Output: З д р а в с т в у й т е

// Itera sui byte
for b in s.bytes() {
    print!("{} ", b);
}
println!();
// Output: 208 151 208 180 ... (24 byte totali)
```

### Slicing di stringhe

```rust
let s = String::from("Ciao mondo");

// Prende i primi 4 byte
let ciao = &s[0..4];
assert_eq!(ciao, "Ciao");

// Prende dal byte 5 in poi
let mondo = &s[5..];
assert_eq!(mondo, "mondo");
```

!!! danger "Panic con caratteri multi-byte"
    ```rust
    let s = String::from("Здравствуйте");
    // let slice = &s[0..1]; // ❌ PANIC! Il byte 1 è nel mezzo di un carattere
    let slice = &s[0..2]; // ✅ OK, 'З' occupa 2 byte
    ```

### Verificare i confini dei caratteri

```rust
let s = String::from("Здравствуйте");

assert!(s.is_char_boundary(0));
assert!(s.is_char_boundary(2)); // Fine di 'З'
assert!(!s.is_char_boundary(1)); // Metà di 'З'
```

## Conversione da/verso Vec&lt;u8&gt;

### Da Vec&lt;u8&gt; a String

```rust
// Con validazione UTF-8
let v = vec![72, 101, 108, 108, 111]; // "Hello"
let s = String::from_utf8(v).expect("UTF-8 non valido");
assert_eq!(s, "Hello");

// Senza validazione (unsafe)
let v = vec![72, 101, 108, 108, 111];
let s = unsafe { String::from_utf8_unchecked(v) };
```

!!! danger "Uso di from_utf8_unchecked"
    `from_utf8_unchecked` è una funzione `unsafe` che non verifica la
    validità UTF-8. Usala solo se sei **assolutamente certo** che i dati
    siano UTF-8 validi, altrimenti causerai undefined behavior!

### Da String a Vec&lt;u8&gt;

```rust
let s = String::from("Ciao");
let v: Vec<u8> = s.into_bytes();
assert_eq!(v, vec![67, 105, 97, 111]);
```

## Gestione della Capacità

### Verificare e riservare capacità

```rust
let mut s = String::new();
assert_eq!(s.capacity(), 0);

s.reserve(10);
assert!(s.capacity() >= 10);

s.push_str("abc");
assert_eq!(s.len(), 3);
assert!(s.capacity() >= 10);
```

### Ridurre la capacità

```rust
let mut s = String::with_capacity(100);
s.push_str("abc");

assert_eq!(s.len(), 3);
assert_eq!(s.capacity(), 100);

s.shrink_to_fit();
assert_eq!(s.capacity(), 3);
```

### Riservare esattamente

```rust
let mut s = String::new();
s.reserve_exact(10);
assert_eq!(s.capacity(), 10); // Esattamente 10, non di più
```

!!! tip "Ottimizzazione della capacità"
    - `reserve(n)` può allocare più di `n` byte per ridurre riallocazioni future
    - `reserve_exact(n)` alloca esattamente `n` byte
    - `shrink_to_fit()` libera memoria inutilizzata (ma può causare riallocazione)

## Metodi di Trasformazione

### Maiuscole e minuscole

```rust
let s = String::from("Ciao Mondo");

let upper = s.to_uppercase();
assert_eq!(upper, "CIAO MONDO");

let lower = s.to_lowercase();
assert_eq!(lower, "ciao mondo");
```

!!! warning "Allocazione"
    `to_uppercase()` e `to_lowercase()` creano nuove `String` invece di modificare quella esistente.

### Replace

```rust
let s = String::from("Ho un gatto. Il gatto è nero.");
let s2 = s.replace("gatto", "cane");
assert_eq!(s2, "Ho un cane. Il cane è nero.");

// Replace limitato (solo le prime n occorrenze)
let s3 = s.replacen("gatto", "cane", 1);
assert_eq!(s3, "Ho un cane. Il gatto è nero.");
```

### Trim (rimuovere spazi)

```rust
let s = String::from("  Ciao mondo  \n");

assert_eq!(s.trim(), "Ciao mondo");
assert_eq!(s.trim_start(), "Ciao mondo  \n");
assert_eq!(s.trim_end(), "  Ciao mondo");
```

## Pattern Matching e Ricerca

### Verificare presenza di sottostringhe

```rust
let s = String::from("Rust è fantastico");

assert!(s.contains("Rust"));
assert!(s.starts_with("Rust"));
assert!(s.ends_with("fantastico"));
```

### Trovare posizioni

```rust
let s = String::from("Rust è fantastico");

assert_eq!(s.find("è"), Some(5)); // Byte 5
assert_eq!(s.find("Java"), None);

assert_eq!(s.rfind("a"), Some(13)); // Ultima 'a' al byte 13
```

### Dividere stringhe

```rust
let s = String::from("Rust,C++,Python,Go");

for linguaggio in s.split(',') {
    println!("{}", linguaggio);
}
// Output: Rust, C++, Python, Go

// Raccogliere in un Vec
let linguaggi: Vec<&str> = s.split(',').collect();
assert_eq!(linguaggi, vec!["Rust", "C++", "Python", "Go"]);
```

### Split su linee

```rust
let s = String::from("riga uno\nriga due\nriga tre");

for linea in s.lines() {
    println!("{}", linea);
}
```

### Split con predicato

```rust
let s = String::from("Rust2025Python2024");

let parti: Vec<&str> = s.split(|c: char| c.is_numeric()).collect();
assert_eq!(parti, vec!["Rust", "", "", "", "", "Python", "", "", "", ""]);

// Split senza elementi vuoti
let parti: Vec<&str> = s.split(|c: char| c.is_numeric())
                          .filter(|s| !s.is_empty())
                          .collect();
assert_eq!(parti, vec!["Rust", "Python"]);
```

## Iteratori

### Caratteri

```rust
let s = String::from("Rust 🦀");

// Itera sui caratteri Unicode
for c in s.chars() {
    println!("{}", c);
}
// Output: R, u, s, t, , 🦀

// Conta caratteri
let count = s.chars().count();
assert_eq!(count, 6); // 4 lettere + 1 spazio + 1 emoji
```

### Byte

```rust
let s = String::from("Rust");

for byte in s.bytes() {
    println!("{}", byte);
}
// Output: 82, 117, 115, 116
```

### Indici dei caratteri

```rust
let s = String::from("Здравствуйте");

for (i, c) in s.char_indices() {
    println!("Carattere '{}' inizia al byte {}", c, i);
}
// Output:
// Carattere 'З' inizia al byte 0
// Carattere 'д' inizia al byte 2
// Carattere 'р' inizia al byte 4
// ...
```

## Parsing

```rust
// Convertire String in numeri
let s = String::from("42");
let n: i32 = s.parse().expect("Non è un numero");
assert_eq!(n, 42);

// Gestire errori elegantemente
let s = String::from("non_un_numero");
match s.parse::<i32>() {
    Ok(n) => println!("Numero: {}", n),
    Err(e) => println!("Errore: {}", e),
}
```

## Drenare (Drain)

```rust
let mut s = String::from("Ciao mondo bello");

// Rimuove e restituisce un range
let drenato: String = s.drain(5..10).collect();
assert_eq!(drenato, "mondo");
assert_eq!(s, "Ciao  bello");
```

!!! tip "Drain vs Remove"
    `drain` rimuove un range di byte e restituisce un iteratore, mentre
    `remove` rimuove un singolo carattere e lo restituisce direttamente.

## Retain

```rust
let mut s = String::from("Rust 2025!");

// Mantiene solo caratteri alfabetici
s.retain(|c| c.is_alphabetic());
assert_eq!(s, "Rust");
```

## Pop

```rust
let mut s = String::from("Rust");

assert_eq!(s.pop(), Some('t'));
assert_eq!(s, "Rus");

assert_eq!(s.pop(), Some('s'));
assert_eq!(s, "Ru");
```

## Confronti e Uguaglianza

```rust
let s1 = String::from("Rust");
let s2 = String::from("Rust");
let s3 = String::from("rust");

assert_eq!(s1, s2);
assert_ne!(s1, s3);

// Confronto case-insensitive
assert!(s1.eq_ignore_ascii_case(&s3));
```

## Conversione da Altri Tipi

```rust
// Da numeri
let num = 42;
let s = num.to_string();
assert_eq!(s, "42");

// Da booleani
let b = true;
let s = b.to_string();
assert_eq!(s, "true");

// Da altri tipi che implementano Display
use std::net::Ipv4Addr;
let ip = Ipv4Addr::new(127, 0, 0, 1);
let s = ip.to_string();
assert_eq!(s, "127.0.0.1");
```

## Metodi Unsafe

Rust fornisce alcuni metodi `unsafe` per operazioni ad alte prestazioni quando hai garanzie esterne sulla validità dei dati:

```rust
// from_utf8_unchecked - salta la validazione UTF-8
let v = vec![72, 101, 108, 108, 111];
let s = unsafe { String::from_utf8_unchecked(v) };

// from_raw_parts - costruisce da componenti raw
let v = vec![72, 101, 108, 108, 111];
let mut v = std::mem::ManuallyDrop::new(v);
let s = unsafe {
    String::from_raw_parts(v.as_mut_ptr(), v.len(), v.capacity())
};

// as_mut_vec - accesso diretto al Vec<u8> interno
let mut s = String::from("Hello");
unsafe {
    let vec = s.as_mut_vec();
    vec.push(33); // Aggiunge '!'
}
assert_eq!(s, "Hello!");
```

!!! danger "Attenzione con i metodi unsafe"
    I metodi `unsafe` bypassano le garanzie di sicurezza di Rust.
    Usali solo quando: (1) hai verificato esternamente la validità UTF-8,
    (2) le prestazioni sono critiche, (3) comprendi appieno le conseguenze.
    L'uso scorretto di metodi `unsafe` può causare undefined behavior!

## Best Practices

### 1. Preferisci &str come parametro

```rust
// ❌ Meno flessibile
fn saluta(nome: String) {
    println!("Ciao, {}!", nome);
}

// ✅ Più flessibile
fn saluta(nome: &str) {
    println!("Ciao, {}!", nome);
}

let s = String::from("Alice");
saluta(&s); // Funziona con String
saluta("Bob"); // Funziona con &str
```

### 2. Usa with_capacity per costruzioni note

```rust
// ❌ Inefficiente - multiple riallocazioni
let mut s = String::new();
for i in 0..1000 {
    s.push_str(&i.to_string());
}

// ✅ Efficiente - preallocazione
let mut s = String::with_capacity(4000);
for i in 0..1000 {
    s.push_str(&i.to_string());
}
```

### 3. Usa format! per concatenazioni complesse

```rust
// ❌ Verboso e inefficiente
let nome = "Alice";
let età = 30;
let mut s = String::from("Nome: ");
s.push_str(nome);
s.push_str(", Età: ");
s.push_str(&età.to_string());

// ✅ Conciso ed efficiente
let s = format!("Nome: {}, Età: {}", nome, età);
```

### 4. Evita clonazioni inutili

```rust
// ❌ Clonazione inutile
fn processa(s: String) -> String {
    s.to_uppercase()
}

let s1 = String::from("test");
let s2 = processa(s1.clone()); // Clonazione costosa
// s1 è ancora disponibile ma abbiamo sprecato memoria

// ✅ Usa reference se puoi
fn processa(s: &str) -> String {
    s.to_uppercase()
}

let s1 = String::from("test");
let s2 = processa(&s1); // Nessuna clonazione
// s1 è ancora disponibile
```

### 5. Gestisci correttamente UTF-8

```rust
// ❌ Può causare panic
let s = String::from("Здравствуйте");
// let slice = &s[0..1]; // PANIC!

// ✅ Verifica i confini o usa chars()
let s = String::from("Здравствуйте");
let primo_char = s.chars().next().unwrap();
assert_eq!(primo_char, 'З');
```

## Performance

### Confronto operazioni

| Operazione | Complessità | Note |
|------------|-------------|------|
| `String::new()` | O(1) | Nessuna allocazione |
| `push_str()` | O(1) ammortizzato | Può causare riallocazione |
| `insert()` | O(n) | Deve spostare tutti i caratteri successivi |
| `len()` | O(1) | Memorizzato come campo |
| `chars().count()` | O(n) | Deve iterare e validare UTF-8 |
| `clone()` | O(n) | Copia tutti i byte |

### Tips per le prestazioni

1. **Preallocare capacità**: Usa `with_capacity` se conosci la dimensione approssimativa
2. **Evitare insert al centro**: Preferisci `push` e `push_str` quando possibile
3. **Usare &str quando possibile**: Evita allocazioni inutili
4. **Attenzione a to_uppercase/to_lowercase**: Allocano nuove String
5. **Considera Vec&lt;u8&gt; per dati non-testuali**: Se non serve validazione UTF-8

## Esempi Pratici

### Costruire un URL con query parameters

```rust
fn build_url(base: &str, params: &[(&str, &str)]) -> String {
    let mut url = String::from(base);
    url.push('?');

    for (i, (key, value)) in params.iter().enumerate() {
        if i > 0 {
            url.push('&');
        }
        url.push_str(key);
        url.push('=');
        url.push_str(value);
    }

    url
}

let url = build_url("https://example.com/search", &[
    ("q", "rust"),
    ("lang", "it"),
    ("page", "1"),
]);

assert_eq!(url, "https://example.com/search?q=rust&lang=it&page=1");
```

### Parsing di CSV semplice

```rust
fn parse_csv_line(line: &str) -> Vec<String> {
    line.split(',')
        .map(|s| s.trim().to_string())
        .collect()
}

let line = "Rust, 2015, Mozilla";
let fields = parse_csv_line(line);
assert_eq!(fields, vec!["Rust", "2015", "Mozilla"]);
```

### Costruire markup HTML

```rust
fn html_paragraph(text: &str, class: Option<&str>) -> String {
    let mut html = String::from("<p");

    if let Some(c) = class {
        html.push_str(" class=\"");
        html.push_str(c);
        html.push('"');
    }

    html.push('>');
    html.push_str(text);
    html.push_str("</p>");

    html
}

let p1 = html_paragraph("Hello, world!", None);
assert_eq!(p1, "<p>Hello, world!</p>");

let p2 = html_paragraph("Highlighted", Some("highlight"));
assert_eq!(p2, "<p class=\"highlight\">Highlighted</p>");
```

### Sanitizzare input utente

```rust
fn sanitize_username(input: &str) -> String {
    input.chars()
        .filter(|c| c.is_alphanumeric() || *c == '_' || *c == '-')
        .take(20) // Massimo 20 caratteri
        .collect()
}

let username = sanitize_username("alice@#$%123!");
assert_eq!(username, "alice123");
```

## Vedi anche

- [str - String slice](https://doc.rust-lang.org/std/primitive.str.html)
- [Vec&lt;T&gt;](../collections/vec.md) - Array dinamico (struttura interna di String)
- [The Book - Capitolo 8.2: Storing UTF-8 Encoded Text with Strings](https://doc.rust-lang.org/book/ch08-02-strings.html)
- [OsString](https://doc.rust-lang.org/std/ffi/struct.OsString.html) - String di sistema (non UTF-8)
- [CString](https://doc.rust-lang.org/std/ffi/struct.CString.html) - String C-compatible

---

!!! question "Hai trovato errori o imprecisioni?"
    Aiutaci a migliorare questa traduzione!
    [Apri una issue](https://github.com/rust-ita/rust-docs-it/issues)
    o proponi una modifica.
