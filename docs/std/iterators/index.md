# Iteratori

!!! info "Riferimento originale"
    📖 [Documentazione originale](https://doc.rust-lang.org/std/iter/)
    🔄 Ultimo aggiornamento: Dicembre 2025
    📝 Versione Rust: 1.90+

Gli **iteratori** (**Iterator**) sono uno dei pattern fondamentali di Rust e rappresentano un meccanismo potente, sicuro ed efficiente per elaborare sequenze di valori. Gli iteratori forniscono un'astrazione unificata per attraversare collezioni di dati, generare sequenze e trasformare valori in modo componibile e funzionale.

## Panoramica

In Rust, gli iteratori sono utilizzati pervasivamente in tutta la standard library e nell'ecosistema. Ogni collezione fornisce modi per creare iteratori, e la maggior parte delle operazioni su sequenze di valori è espressa attraverso metodi di iteratori piuttosto che attraverso loop espliciti.

**Caratteristiche chiave degli iteratori**:

- **Lazy evaluation**: gli iteratori non eseguono calcoli finché non consumati
- **Zero-cost abstraction**: le ottimizzazioni del compilatore rendono gli iteratori veloci quanto loop scritti a mano
- **Componibilità**: i metodi degli iteratori possono essere concatenati per creare pipeline di elaborazione complesse
- **Sicurezza**: il borrow checker garantisce che gli iteratori rispettino le regole di ownership

```rust
let numbers = vec![1, 2, 3, 4, 5];

// Iteratore che trasforma, filtra e somma - tutto in modo lazy
let sum: i32 = numbers.iter()
    .map(|x| x * 2)      // moltiplica per 2
    .filter(|x| x > &5)  // mantieni solo i valori > 5
    .sum();              // consuma e somma

assert_eq!(sum, 18); // 6 + 8 + 10
```

A differenza di linguaggi come Python o JavaScript dove gli iteratori sono spesso un dettaglio di implementazione, in Rust sono un costrutto di prima classe con un trait ben definito e un ricco ecosistema di metodi.

---

## Il Trait Iterator

Al cuore del sistema di iteratori in Rust c'è il trait **`Iterator`**, che definisce l'interfaccia comune per tutti gli iteratori.

### Definizione

```rust
pub trait Iterator {
    type Item;

    fn next(&mut self) -> Option<Self::Item>;

    // ... molti altri metodi forniti automaticamente
}
```

Il trait Iterator richiede solo:

1. **Type associato `Item`**: il tipo degli elementi prodotti dall'iteratore
2. **Metodo `next()`**: restituisce il prossimo elemento come `Some(item)` o `None` quando l'iteratore è esaurito

Tutti gli altri ~80 metodi del trait Iterator (come `map`, `filter`, `collect`, ecc.) sono forniti automaticamente attraverso implementazioni default che si basano su `next()`.

### Il Metodo `next()`

`next()` è il cuore pulsante di ogni iteratore. Ogni chiamata a `next()`:

- Prende `&mut self` perché avanza lo stato interno dell'iteratore
- Restituisce `Option<Self::Item>`:
  - `Some(valore)` se c'è un altro elemento
  - `None` se l'iteratore è esaurito

!!! warning "Comportamento dopo None"
    Una volta che `next()` restituisce `None`, il comportamento delle chiamate successive non è specificato dal trait base `Iterator`. Alcuni iteratori continuano a restituire `None`, altri potrebbero produrre nuovi valori. Per un comportamento garantito, usa il trait `FusedIterator` o l'adapter `fuse()`.

### Uso Diretto di `next()`

Anche se raramente necessario, puoi chiamare `next()` direttamente:

```rust
let mut numbers = vec![1, 2, 3].into_iter();

assert_eq!(numbers.next(), Some(1));
assert_eq!(numbers.next(), Some(2));
assert_eq!(numbers.next(), Some(3));
assert_eq!(numbers.next(), None);
assert_eq!(numbers.next(), None); // Continua a restituire None
```

### Iteratori su Tipi Comuni

Rust fornisce iteratori per tutti i tipi comuni:

```rust
// Array e slice
let arr = [10, 20, 30];
for x in arr.iter() {
    println!("{}", x);
}

// Range
for i in 0..5 {
    println!("{}", i);
}

// Stringhe (iterazione su caratteri)
let text = "Ciao";
for c in text.chars() {
    println!("{}", c);
}
```

!!! tip "I cicli for usano automaticamente gli iteratori"
    In Rust, `for x in collection` è zucchero sintattico per creare un iteratore e chiamare `next()` ripetutamente. Approfondiremo questo nella sezione IntoIterator.

---

## Le Tre Forme di Iterazione

Uno degli aspetti più importanti degli iteratori in Rust è la distinzione tra **tre modi** di iterare su una collezione, ognuno con semantiche diverse rispetto a ownership e mutabilità:

1. **`iter()`** - Iterazione su riferimenti immutabili (`&T`)
2. **`iter_mut()`** - Iterazione su riferimenti mutabili (`&mut T`)
3. **`into_iter()`** - Iterazione per valore, consumando la collezione (`T`)

La scelta tra questi metodi determina:

- Se puoi modificare gli elementi
- Se la collezione originale viene consumata
- Se puoi usare la collezione dopo l'iterazione

### `iter()` - Riferimenti Immutabili

`iter()` crea un iteratore che produce **riferimenti immutabili** agli elementi. La collezione originale:

- **Non viene modificata**
- **Non viene consumata**
- **Può essere usata dopo l'iterazione**

```rust
let numbers = vec![1, 2, 3, 4, 5];

// Itera su riferimenti &i32
for num in numbers.iter() {
    println!("{}", num); // num è &i32
}

// numbers è ancora utilizzabile
println!("Somma: {}", numbers.iter().sum::<i32>());
```

**Quando usare `iter()`**:

- Quando vuoi solo leggere i valori
- Quando devi usare la collezione dopo l'iterazione
- Quando vuoi iterare più volte sulla stessa collezione

```rust
let words = vec!["hello", "world"];

// Prima iterazione
let lengths: Vec<usize> = words.iter().map(|s| s.len()).collect();

// Seconda iterazione - words è ancora disponibile
let uppercase: Vec<String> = words.iter().map(|s| s.to_uppercase()).collect();

assert_eq!(lengths, vec![5, 5]);
assert_eq!(uppercase, vec!["HELLO", "WORLD"]);
```

### `iter_mut()` - Riferimenti Mutabili

`iter_mut()` crea un iteratore che produce **riferimenti mutabili** agli elementi. Questo ti permette di:

- **Modificare gli elementi sul posto**
- **Mantenere la collezione dopo l'iterazione**

```rust
let mut numbers = vec![1, 2, 3, 4, 5];

// Itera su riferimenti &mut i32
for num in numbers.iter_mut() {
    *num *= 2; // Moltiplica ogni elemento per 2
}

assert_eq!(numbers, vec![2, 4, 6, 8, 10]);
```

**Quando usare `iter_mut()`**:

- Quando vuoi modificare gli elementi in place
- Quando la logica di modifica è complessa
- Per evitare di allocare una nuova collezione

```rust
let mut scores = vec![85, 90, 78, 92, 88];

// Applica un bonus del 5% a tutti i punteggi
for score in scores.iter_mut() {
    *score = (*score as f64 * 1.05) as i32;
}

assert_eq!(scores, vec![89, 94, 81, 96, 92]);
```

!!! note "Regole di borrowing"
    `iter_mut()` prende un riferimento mutabile alla collezione, quindi non puoi avere altri riferimenti (mutabili o immutabili) alla collezione mentre l'iteratore è attivo. Questo è garantito dal borrow checker.

### `into_iter()` - Consumo per Valore

`into_iter()` **consuma la collezione** e produce i suoi elementi **per valore** (non per riferimento). Dopo aver chiamato `into_iter()`:

- **La collezione originale non è più utilizzabile**
- **Gli elementi sono trasferiti fuori dalla collezione**

```rust
let numbers = vec![1, 2, 3, 4, 5];

// Itera su valori i32 (non &i32)
for num in numbers.into_iter() {
    println!("{}", num); // num è i32, non &i32
}

// ❌ ERRORE: numbers è stato consumato (moved)
// println!("{:?}", numbers);
```

**Quando usare `into_iter()`**:

- Quando non hai più bisogno della collezione originale
- Quando vuoi trasferire i valori in una nuova collezione
- Per evitare cloni non necessari quando trasferisci ownership

```rust
let words = vec![String::from("hello"), String::from("world")];

// Trasferisce gli String in una nuova collezione
let uppercase: Vec<String> = words.into_iter()
    .map(|s| s.to_uppercase())
    .collect();

assert_eq!(uppercase, vec!["HELLO", "WORLD"]);
// ❌ words non è più disponibile
```

#### Uso con `extend` e `collect`

`into_iter()` è particolarmente utile con metodi come `extend` e `collect` che costruiscono nuove collezioni:

```rust
let mut vec1 = vec![1, 2, 3];
let vec2 = vec![4, 5, 6];

// extend chiama automaticamente into_iter()
vec1.extend(vec2); // vec2 viene consumato

assert_eq!(vec1, vec![1, 2, 3, 4, 5, 6]);
```

```rust
use std::collections::VecDeque;

let vec = vec![1, 2, 3, 4];

// Converti Vec in VecDeque usando into_iter + collect
let deque: VecDeque<_> = vec.into_iter().collect();

assert_eq!(deque.len(), 4);
```

### Pattern Riassuntivo

Il pattern più comune per scegliere tra i tre metodi:

```rust
let mut collection = vec![1, 2, 3, 4, 5];

// Lettura - usa &collection o .iter()
for x in &collection {           // equivalente a collection.iter()
    println!("{}", x);
}

// Modifica - usa &mut collection o .iter_mut()
for x in &mut collection {       // equivalente a collection.iter_mut()
    *x += 1;
}

// Consumo - usa collection o .into_iter()
for x in collection {            // equivalente a collection.into_iter()
    println!("{}", x);
}
// collection non è più utilizzabile qui
```

!!! tip "Sintassi abbreviata con cicli for"
    Nei cicli `for`, puoi usare:
    - `for x in &collection` → equivalente a `collection.iter()`
    - `for x in &mut collection` → equivalente a `collection.iter_mut()`
    - `for x in collection` → equivalente a `collection.into_iter()`

### Tabella Riassuntiva

| Metodo | Tipo Elemento | Consuma Collezione | Può Modificare | Uso Dopo Iterazione |
|--------|---------------|---------------------|----------------|---------------------|
| `iter()` | `&T` | ❌ No | ❌ No | ✅ Sì |
| `iter_mut()` | `&mut T` | ❌ No | ✅ Sì | ✅ Sì |
| `into_iter()` | `T` | ✅ Sì | N/A | ❌ No |

---

## IntoIterator e Cicli For

Quando scrivi un ciclo `for` in Rust, stai in realtà usando il trait **`IntoIterator`**, che è il meccanismo che permette di convertire qualcosa in un iteratore.

### Il Trait IntoIterator

```rust
pub trait IntoIterator {
    type Item;
    type IntoIter: Iterator<Item = Self::Item>;

    fn into_iter(self) -> Self::IntoIter;
}
```

`IntoIterator` definisce come un tipo può essere convertito in un iteratore. Ogni ciclo `for` è zucchero sintattico per chiamare `into_iter()`:

```rust
// Questo codice...
for x in collection {
    // ...
}

// ...è equivalente a questo:
{
    let mut iter = IntoIterator::into_iter(collection);
    while let Some(x) = iter.next() {
        // ...
    }
}
```

### Tre Implementazioni per Collezioni

Le collezioni standard in Rust implementano `IntoIterator` in **tre modi**:

```rust
// 1. Per T (la collezione stessa)
impl<T> IntoIterator for Vec<T> {
    type Item = T;
    // ... restituisce un iteratore che consuma il Vec
}

// 2. Per &T (riferimento immutabile alla collezione)
impl<'a, T> IntoIterator for &'a Vec<T> {
    type Item = &'a T;
    // ... restituisce un iteratore sui riferimenti
}

// 3. Per &mut T (riferimento mutabile alla collezione)
impl<'a, T> IntoIterator for &'a mut Vec<T> {
    type Item = &'a mut T;
    // ... restituisce un iteratore sui riferimenti mutabili
}
```

Questo spiega perché puoi scrivere:

```rust
let vec = vec![1, 2, 3];

for x in vec { }        // IntoIterator per Vec<i32> → consuma
for x in &vec { }       // IntoIterator per &Vec<i32> → riferimenti
for x in &mut vec { }   // IntoIterator per &mut Vec<i32> → riferimenti mut
```

### IntoIterator vs Iterator

È importante distinguere:

- **`Iterator`**: un tipo che può produrre una sequenza di valori tramite `next()`
- **`IntoIterator`**: un tipo che può essere convertito in un `Iterator`

Tutti gli `Iterator` implementano automaticamente `IntoIterator` (restituendo se stessi):

```rust
impl<I: Iterator> IntoIterator for I {
    type Item = I::Item;
    type IntoIter = I;

    fn into_iter(self) -> I {
        self
    }
}
```

Questo permette di usare iteratori direttamente nei cicli for:

```rust
let numbers = vec![1, 2, 3];
let iter = numbers.iter(); // iter è già un Iterator

for x in iter {  // IntoIterator per Iterator restituisce se stesso
    println!("{}", x);
}
```

### Implementare IntoIterator per Tipi Custom

Puoi implementare `IntoIterator` per i tuoi tipi per abilitare l'uso nei cicli `for`:

```rust
struct Countdown {
    count: u32,
}

impl Iterator for Countdown {
    type Item = u32;

    fn next(&mut self) -> Option<Self::Item> {
        if self.count > 0 {
            self.count -= 1;
            Some(self.count)
        } else {
            None
        }
    }
}

impl IntoIterator for Countdown {
    type Item = u32;
    type IntoIter = Self;

    fn into_iter(self) -> Self::IntoIter {
        self
    }
}

// Ora possiamo usare Countdown in un for loop
for i in Countdown { count: 5 } {
    println!("{}", i); // 4, 3, 2, 1, 0
}
```

!!! tip "Quando implementare IntoIterator"
    Se stai creando una collezione custom o un tipo che rappresenta una sequenza, implementare `IntoIterator` lo rende ergonomico da usare con i cicli `for` e con metodi come `extend`.

---

## Lazy Evaluation

Una delle caratteristiche più importanti e distintive degli iteratori in Rust è la **lazy evaluation** (valutazione pigra). Gli iteratori non eseguono alcun lavoro finché non vengono **consumati**.

### Concetto di Lazy Evaluation

In Rust, gli **adapter** degli iteratori (come `map`, `filter`, `take`, ecc.) costruiscono nuovi iteratori senza eseguire alcun calcolo:

```rust
let numbers = vec![1, 2, 3, 4, 5];

// Questa catena non fa ancora nulla!
let iter = numbers.iter()
    .map(|x| x * 2)       // Non esegue moltiplicazioni
    .filter(|x| x > &5);   // Non esegue controlli

// Il lavoro avviene solo quando consumiamo l'iteratore
let result: Vec<i32> = iter.collect(); // <-- QUI avviene tutto il lavoro
assert_eq!(result, vec![6, 8, 10]);
```

### Dimostrazione con Println

Un modo efficace per vedere la lazy evaluation in azione è usare `println!` nelle closure:

```rust
let numbers = vec![1, 2, 3];

println!("Creazione dell'iteratore...");
let iter = numbers.iter()
    .map(|x| {
        println!("  Mappando {}", x);
        x * 2
    })
    .filter(|x| {
        println!("  Filtrando {}", x);
        x > &3
    });

println!("Iteratore creato, ma nessun output ancora!");

println!("Consumazione con collect...");
let result: Vec<i32> = iter.collect();

println!("Risultato: {:?}", result);
```

Output:

```
Creazione dell'iteratore...
Iteratore creato, ma nessun output ancora!
Consumazione con collect...
  Mappando 1
  Filtrando 2
  Mappando 2
  Filtrando 4
  Mappando 3
  Filtrando 6
Risultato: [4, 6]
```

### Eager vs Lazy

Confrontiamo l'approccio eager (ansioso) con quello lazy:

**Eager (tipico in linguaggi come Python o JavaScript)**:

```rust
let numbers = vec![1, 2, 3, 4, 5];

// Approccio eager (simulato) - crea collezioni intermedie
let doubled: Vec<i32> = numbers.iter().map(|x| x * 2).collect();
let filtered: Vec<i32> = doubled.iter().filter(|x| x > &5).cloned().collect();
// Problema: alloca due Vec temporanei
```

**Lazy (idiomatico in Rust)**:

```rust
let numbers = vec![1, 2, 3, 4, 5];

// Approccio lazy - una sola allocazione
let result: Vec<i32> = numbers.iter()
    .map(|x| x * 2)
    .filter(|x| x > &5)
    .cloned()
    .collect();
// Vantaggio: nessuna allocazione intermedia
```

### Vantaggi della Lazy Evaluation

#### 1. **Performance**: Nessuna Allocazione Intermedia

Gli adapter lazy non allocano collezioni temporanee:

```rust
let numbers: Vec<i32> = (0..1_000_000).collect();

// Nessuna allocazione intermedia, solo il risultato finale
let result: Vec<i32> = numbers.iter()
    .map(|x| x * 2)
    .filter(|x| x % 3 == 0)
    .take(100)
    .cloned()
    .collect();
// Solo UNA allocazione per il Vec finale
```

#### 2. **Short-Circuiting**: Calcoli Minimi

Gli iteratori lazy si fermano non appena possibile:

```rust
let numbers = vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

// find() si ferma al primo match
let first_even = numbers.iter()
    .map(|x| {
        println!("Controllando {}", x);
        x
    })
    .find(|x| *x % 2 == 0);

// Output:
// Controllando 1
// Controllando 2
// (si ferma qui!)

assert_eq!(first_even, Some(&2));
```

#### 3. **Iteratori Infiniti**: Possibili Grazie a Lazy

Puoi creare iteratori infiniti che funzionano perché lazy:

```rust
let fibonacci = std::iter::successors(
    Some((0, 1)),
    |&(a, b)| Some((b, a + b))
).map(|(a, _)| a);

// Prende solo i primi 10 numeri di Fibonacci
let first_10: Vec<u64> = fibonacci.take(10).collect();
assert_eq!(first_10, vec![0, 1, 1, 2, 3, 5, 8, 13, 21, 34]);

// Senza take(), questo sarebbe un loop infinito!
```

### Il Pattern della Pipeline

La lazy evaluation abilita il pattern delle **pipeline di iteratori**, una sequenza di trasformazioni che viene ottimizzata come un singolo pass:

```rust
let text = "hello world from rust";

let result: String = text.split_whitespace()  // Iteratore sulle parole
    .filter(|w| w.len() > 4)                  // Solo parole lunghe
    .map(|w| w.to_uppercase())                // Maiuscole
    .collect::<Vec<_>>()                      // Colleziona
    .join("-");                               // Unisci con "-"

assert_eq!(result, "HELLO-WORLD");
```

Il compilatore può ottimizzare questa pipeline in un singolo loop senza allocazioni intermedie.

!!! tip "Quando la lazy evaluation aiuta"
    - **Grandi dataset**: evita allocazioni di collezioni intermedie
    - **Short-circuiting**: usa `find`, `any`, `all` per fermarti presto
    - **Iteratori infiniti**: combina con `take` o `take_while` per generare sequenze infinite controllate

!!! warning "Attenzione agli effetti collaterali"
    Poiché gli adapter sono lazy, gli effetti collaterali nelle closure non avvengono finché l'iteratore non è consumato. Se hai bisogno di effetti collaterali immediati, usa `for_each` (che è un consumer) invece di `map`.

---

## Adapter - Filtraggio e Mappatura

Gli **adapter** sono metodi che trasformano un iteratore in un altro iteratore. Non consumano l'iteratore originale, ma creano un nuovo iteratore che applica una trasformazione. Gli adapter più comuni sono quelli che **mappano** (trasformano) e **filtrano** (selezionano) elementi.

### Varianti Map

#### `map()` - Trasformazione 1-a-1

`map()` trasforma ogni elemento dell'iteratore applicando una funzione:

```rust
let numbers = vec![1, 2, 3, 4, 5];
let doubled: Vec<i32> = numbers.iter().map(|x| x * 2).collect();

assert_eq!(doubled, vec![2, 4, 6, 8, 10]);
```

**Casi d'uso comuni**:

```rust
// Convertire tipi
let numbers = vec![1, 2, 3];
let strings: Vec<String> = numbers.iter()
    .map(|n| n.to_string())
    .collect();

// Estrarre campi da struct
struct Person { name: String, age: u32 }
let people = vec![
    Person { name: "Alice".into(), age: 30 },
    Person { name: "Bob".into(), age: 25 },
];
let names: Vec<String> = people.iter()
    .map(|p| p.name.clone())
    .collect();
```

#### `filter_map()` - Filtra e Mappa in Un Passo

`filter_map()` combina `filter` e `map`: applica una funzione che restituisce `Option`, mantenendo solo i valori `Some`:

```rust
let strings = vec!["1", "due", "3", "quattro", "5"];
let numbers: Vec<i32> = strings.iter()
    .filter_map(|s| s.parse().ok())
    .collect();

assert_eq!(numbers, vec![1, 3, 5]);
```

È più efficiente di chain di `filter` + `map`:

```rust
// ❌ Meno efficiente
let result: Vec<i32> = strings.iter()
    .map(|s| s.parse::<i32>())
    .filter(|r| r.is_ok())
    .map(|r| r.unwrap())
    .collect();

// ✅ Più efficiente
let result: Vec<i32> = strings.iter()
    .filter_map(|s| s.parse().ok())
    .collect();
```

#### `flat_map()` - Mappa e Appiattisce

`flat_map()` mappa ogni elemento a un iteratore, poi appiattisce il risultato:

```rust
let words = vec!["hello world", "foo bar"];
let all_words: Vec<&str> = words.iter()
    .flat_map(|s| s.split_whitespace())
    .collect();

assert_eq!(all_words, vec!["hello", "world", "foo", "bar"]);
```

Utile per trasformazioni 1-a-molti:

```rust
let ranges = vec![1..3, 5..7];
let all_numbers: Vec<i32> = ranges.into_iter()
    .flat_map(|r| r)
    .collect();

assert_eq!(all_numbers, vec![1, 2, 5, 6]);
```

#### `flatten()` - Solo Appiattimento

`flatten()` appiattisce iteratori annidati senza trasformazione:

```rust
let nested = vec![vec![1, 2], vec![3, 4], vec![5]];
let flat: Vec<i32> = nested.into_iter()
    .flatten()
    .collect();

assert_eq!(flat, vec![1, 2, 3, 4, 5]);
```

### Varianti Filter

#### `filter()` - Selezione per Predicato

`filter()` mantiene solo gli elementi che soddisfano un predicato:

```rust
let numbers = vec![1, 2, 3, 4, 5, 6];
let evens: Vec<i32> = numbers.iter()
    .filter(|x| *x % 2 == 0)
    .cloned()
    .collect();

assert_eq!(evens, vec![2, 4, 6]);
```

**Casi d'uso comuni**:

```rust
// Filtrare stringhe
let words = vec!["hello", "world", "rust", "is", "great"];
let long_words: Vec<&str> = words.iter()
    .filter(|w| w.len() > 4)
    .cloned()
    .collect();

assert_eq!(long_words, vec!["hello", "world", "great"]);

// Filtrare con condizioni multiple
let numbers = vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
let result: Vec<i32> = numbers.iter()
    .filter(|x| *x % 2 == 0 && *x > 5)
    .cloned()
    .collect();

assert_eq!(result, vec![6, 8, 10]);
```

#### `take_while()` - Prendi Mentre Condizione Vera

`take_while()` prende elementi finché un predicato è vero, poi si ferma:

```rust
let numbers = vec![1, 2, 3, 4, 1, 2];
let result: Vec<i32> = numbers.iter()
    .take_while(|x| **x < 4)
    .cloned()
    .collect();

assert_eq!(result, vec![1, 2, 3]);
// Si ferma a 4, ignora i valori successivi
```

#### `skip_while()` - Salta Mentre Condizione Vera

`skip_while()` salta elementi finché un predicato è vero, poi prende tutto il resto:

```rust
let numbers = vec![1, 2, 3, 4, 5, 6];
let result: Vec<i32> = numbers.iter()
    .skip_while(|x| **x < 4)
    .cloned()
    .collect();

assert_eq!(result, vec![4, 5, 6]);
```

**Differenza tra `filter` e `take_while`/`skip_while`**:

```rust
let numbers = vec![1, 2, 3, 4, 1, 2];

// filter: valuta ogni elemento
let filtered: Vec<i32> = numbers.iter()
    .filter(|x| **x < 3)
    .cloned()
    .collect();
assert_eq!(filtered, vec![1, 2, 1, 2]);

// take_while: si ferma alla prima condizione falsa
let taken: Vec<i32> = numbers.iter()
    .take_while(|x| **x < 3)
    .cloned()
    .collect();
assert_eq!(taken, vec![1, 2]);
```

---

## Adapter - Limitazione e Selezione

Gli adapter di limitazione controllano quanti elementi produrre o saltare dall'iteratore.

### `take(n)` - Primi n Elementi

`take()` crea un iteratore che produce al massimo i primi `n` elementi:

```rust
let numbers = vec![1, 2, 3, 4, 5];
let first_three: Vec<i32> = numbers.iter().take(3).cloned().collect();

assert_eq!(first_three, vec![1, 2, 3]);
```

Sicuro con iteratori più corti:

```rust
let numbers = vec![1, 2];
let taken: Vec<i32> = numbers.iter().take(5).cloned().collect();

assert_eq!(taken, vec![1, 2]); // Solo 2 elementi disponibili
```

### `skip(n)` - Salta Primi n Elementi

`skip()` crea un iteratore che salta i primi `n` elementi:

```rust
let numbers = vec![1, 2, 3, 4, 5];
let after_two: Vec<i32> = numbers.iter().skip(2).cloned().collect();

assert_eq!(after_two, vec![3, 4, 5]);
```

### Paginazione con `skip` e `take`

Combinare `skip` e `take` è il pattern classico per la paginazione:

```rust
fn paginate<T: Clone>(items: &[T], page: usize, page_size: usize) -> Vec<T> {
    items.iter()
        .skip(page * page_size)
        .take(page_size)
        .cloned()
        .collect()
}

let items = vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

assert_eq!(paginate(&items, 0, 3), vec![1, 2, 3]);    // Pagina 1
assert_eq!(paginate(&items, 1, 3), vec![4, 5, 6]);    // Pagina 2
assert_eq!(paginate(&items, 2, 3), vec![7, 8, 9]);    // Pagina 3
assert_eq!(paginate(&items, 3, 3), vec![10]);         // Pagina 4
```

### `step_by(n)` - Ogni n-esimo Elemento

`step_by()` prende ogni n-esimo elemento, saltando gli intermedi:

```rust
let numbers = vec![0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
let every_third: Vec<i32> = numbers.iter().step_by(3).cloned().collect();

assert_eq!(every_third, vec![0, 3, 6, 9]);
```

Utile per campionamento:

```rust
// Prendi un campione del 10% di un grande dataset
let large_data: Vec<i32> = (0..1000).collect();
let sample: Vec<i32> = large_data.iter().step_by(10).cloned().collect();

assert_eq!(sample.len(), 100);
```

### `nth(n)` - Elemento Specifico (Consuma!)

`nth()` restituisce l'n-esimo elemento, ma **consuma tutti gli elementi precedenti**:

```rust
let numbers = vec![0, 1, 2, 3, 4, 5];
let mut iter = numbers.iter();

assert_eq!(iter.nth(2), Some(&2)); // Ottiene indice 2
assert_eq!(iter.nth(0), Some(&3)); // Prossimo elemento (indice 3 originale)
```

!!! warning "Attenzione con nth() nei loop"
    **NON usare `nth()` in un loop** per accedere a tutti gli elementi - è molto inefficiente:

    ```rust
    let numbers = vec![1, 2, 3, 4, 5];

    // ❌ ANTI-PATTERN: O(n²) complessità!
    for i in 0..numbers.len() {
        if let Some(x) = numbers.iter().nth(i) {
            println!("{}", x);
        }
    }

    // ✅ Usa direttamente l'iteratore: O(n)
    for x in numbers.iter() {
        println!("{}", x);
    }
    ```

Usa `nth()` solo per accedere a un singolo elemento specifico.

---

## Adapter - Combinazione

Gli adapter di combinazione permettono di unire, accoppiare e manipolare più iteratori insieme.

### `chain()` - Concatena Due Iteratori

`chain()` concatena due iteratori, producendo prima tutti gli elementi del primo, poi del secondo:

```rust
let a = vec![1, 2, 3];
let b = vec![4, 5, 6];

let chained: Vec<i32> = a.iter().chain(b.iter()).cloned().collect();

assert_eq!(chained, vec![1, 2, 3, 4, 5, 6]);
```

Utile per combinare più fonti:

```rust
let header = vec!["Name", "Age"];
let data = vec!["Alice", "30", "Bob", "25"];

let all: Vec<&str> = header.iter()
    .chain(data.iter())
    .cloned()
    .collect();
```

Puoi concatenare più iteratori:

```rust
let a = vec![1, 2];
let b = vec![3, 4];
let c = vec![5, 6];

let result: Vec<i32> = a.iter()
    .chain(b.iter())
    .chain(c.iter())
    .cloned()
    .collect();

assert_eq!(result, vec![1, 2, 3, 4, 5, 6]);
```

### `zip()` - Combina Elementi in Coppie

`zip()` prende due iteratori e produce un iteratore di tuple, accoppiando elementi dalla stessa posizione:

```rust
let names = vec!["Alice", "Bob", "Charlie"];
let ages = vec![30, 25, 35];

let people: Vec<_> = names.iter().zip(ages.iter()).collect();

assert_eq!(people, vec![
    (&"Alice", &30),
    (&"Bob", &25),
    (&"Charlie", &35),
]);
```

Si ferma quando il più corto finisce:

```rust
let a = vec![1, 2, 3];
let b = vec!['a', 'b'];

let zipped: Vec<_> = a.iter().zip(b.iter()).collect();

assert_eq!(zipped, vec![(&1, &'a'), (&2, &'b')]);
// Solo 2 coppie perché b ha solo 2 elementi
```

**Casi d'uso comuni**:

```rust
// Creare una HashMap da chiavi e valori
use std::collections::HashMap;

let keys = vec!["one", "two", "three"];
let values = vec![1, 2, 3];

let map: HashMap<_, _> = keys.into_iter().zip(values.into_iter()).collect();

assert_eq!(map.get("two"), Some(&2));
```

### `enumerate()` - Aggiunge Indici

`enumerate()` trasforma un iteratore di `T` in un iteratore di `(usize, T)`, dove il primo elemento è l'indice:

```rust
let words = vec!["zero", "one", "two"];
let indexed: Vec<_> = words.iter().enumerate().collect();

assert_eq!(indexed, vec![
    (0, &"zero"),
    (1, &"one"),
    (2, &"two"),
]);
```

Molto utile quando serve sia l'indice che il valore:

```rust
let items = vec!["apple", "banana", "cherry"];

for (i, item) in items.iter().enumerate() {
    println!("{}: {}", i + 1, item);
}
// Output:
// 1: apple
// 2: banana
// 3: cherry
```

### `cycle()` - Ripete Infinitamente

`cycle()` crea un iteratore che ripete la sequenza all'infinito:

```rust
let colors = vec!["red", "green", "blue"];
let cycled: Vec<&str> = colors.iter().cycle().take(7).cloned().collect();

assert_eq!(cycled, vec!["red", "green", "blue", "red", "green", "blue", "red"]);
```

!!! danger "ATTENZIONE: Iteratori Infiniti!"
    `cycle()` crea un iteratore infinito. **Devi sempre usare `take()` o `take_while()`** per limitarlo, altrimenti avrai un loop infinito!

    ```rust
    let numbers = vec![1, 2, 3];

    // ❌ ERRORE: loop infinito!
    // let sum: i32 = numbers.iter().cycle().sum();

    // ✅ CORRETTO: limitato con take
    let sum: i32 = numbers.iter().cycle().take(9).sum();
    assert_eq!(sum, 18); // (1+2+3) * 3
    ```

**Casi d'uso**:

```rust
// Distribuire task in round-robin
let workers = vec!["Worker1", "Worker2", "Worker3"];
let tasks = vec!["Task A", "Task B", "Task C", "Task D", "Task E"];

let assignments: Vec<_> = tasks.iter()
    .zip(workers.iter().cycle())
    .collect();

// Task A -> Worker1, Task B -> Worker2, Task C -> Worker3,
// Task D -> Worker1, Task E -> Worker2
```

### `rev()` - Ordine Inverso

`rev()` inverte l'ordine di un iteratore (richiede che l'iteratore implementi `DoubleEndedIterator`):

```rust
let numbers = vec![1, 2, 3, 4, 5];
let reversed: Vec<i32> = numbers.iter().rev().cloned().collect();

assert_eq!(reversed, vec![5, 4, 3, 2, 1]);
```

Utile per elaborare dall'ultimo al primo:

```rust
let items = vec!["first", "second", "third"];

for item in items.iter().rev() {
    println!("{}", item);
}
// Output:
// third
// second
// first
```

Combinabile con altri adapter:

```rust
let numbers = vec![1, 2, 3, 4, 5, 6];

// Prendi gli ultimi 3 elementi in ordine inverso
let last_three: Vec<i32> = numbers.iter().rev().take(3).cloned().collect();
assert_eq!(last_three, vec![6, 5, 4]);

// Prendi gli ultimi 3 elementi in ordine normale
let last_three_normal: Vec<i32> = numbers.iter()
    .rev()
    .take(3)
    .rev()
    .cloned()
    .collect();
assert_eq!(last_three_normal, vec![4, 5, 6]);
```

---

## Adapter - Trasformazioni Stateful

### `scan()` - Trasformazione con Stato

```rust
let numbers = vec![1, 2, 3, 4];
let running_sum: Vec<i32> = numbers.iter()
    .scan(0, |state, x| {
        *state += x;
        Some(*state)
    })
    .collect();

assert_eq!(running_sum, vec![1, 3, 6, 10]);
```

### `inspect()` - Debug della Pipeline

```rust
let sum: i32 = (1..=5)
    .inspect(|x| println!("valore: {}", x))
    .map(|x| x * 2)
    .inspect(|x| println!("dopo map: {}", x))
    .sum();
```

### `cloned()` / `copied()` - Copia Elementi

```rust
let nums = vec![1, 2, 3];
let owned: Vec<i32> = nums.iter().cloned().collect();
```

### `peekable()` - Guarda Avanti

```rust
let nums = vec![1, 2, 3];
let mut iter = nums.iter().peekable();

if let Some(&&first) = iter.peek() {
    println!("Primo: {}", first); // Non consuma
}
assert_eq!(iter.next(), Some(&1)); // Ora consuma
```

---

## Consumer - Aggregazione

I **consumer** sono metodi che consumano l'iteratore e producono un valore finale.

### `collect()` - Costruire Collezioni

```rust
use std::collections::{HashMap, HashSet, VecDeque};

let nums = vec![1, 2, 3];

// Vec
let v: Vec<i32> = nums.iter().cloned().collect();

// HashSet
let set: HashSet<i32> = nums.iter().cloned().collect();

// String
let chars = vec!['h', 'e', 'l', 'l', 'o'];
let s: String = chars.iter().collect();

// HashMap
let pairs = vec![("a", 1), ("b", 2)];
let map: HashMap<_, _> = pairs.into_iter().collect();
```

### `fold()` - Riduzione con Accumulatore

```rust
let nums = vec![1, 2, 3, 4];
let sum = nums.iter().fold(0, |acc, x| acc + x);
assert_eq!(sum, 10);

// Concatenare stringhe
let words = vec!["hello", "world"];
let sentence = words.iter().fold(String::new(), |acc, w| acc + w + " ");
```

### `reduce()` - Riduzione Senza Iniziale

```rust
let nums = vec![1, 2, 3, 4];
let sum = nums.iter().reduce(|acc, x| acc + x);
assert_eq!(sum, Some(&10));
```

### `sum()` / `product()` - Aggregazione Numerica

```rust
let nums = vec![1, 2, 3, 4];
let sum: i32 = nums.iter().sum();
let product: i32 = nums.iter().product();

assert_eq!(sum, 10);
assert_eq!(product, 24);
```

---

## Consumer - Ricerca e Verifica

### `find()` - Primo Elemento Soddisfacente

```rust
let nums = vec![1, 2, 3, 4, 5];
let first_even = nums.iter().find(|x| *x % 2 == 0);
assert_eq!(first_even, Some(&2));
```

### `position()` - Indice del Primo Match

```rust
let nums = vec![1, 2, 3, 4];
let pos = nums.iter().position(|x| *x == 3);
assert_eq!(pos, Some(2));
```

### `any()` / `all()` - Verifica Predicati

```rust
let nums = vec![1, 2, 3];
assert!(nums.iter().any(|x| *x > 2));
assert!(nums.iter().all(|x| *x > 0));
```

### `count()`, `last()`, `max()`, `min()`

```rust
let nums = vec![3, 1, 4, 1, 5];

assert_eq!(nums.iter().count(), 5);
assert_eq!(nums.iter().last(), Some(&5));
assert_eq!(nums.iter().max(), Some(&5));
assert_eq!(nums.iter().min(), Some(&1));
```

---

## Consumer - Organizzazione

### `partition()` - Divide in Due Collezioni

```rust
let nums = vec![1, 2, 3, 4, 5, 6];
let (evens, odds): (Vec<i32>, Vec<i32>) = nums.into_iter()
    .partition(|x| x % 2 == 0);

assert_eq!(evens, vec![2, 4, 6]);
assert_eq!(odds, vec![1, 3, 5]);
```

### `for_each()` - Effetti Collaterali

```rust
let nums = vec![1, 2, 3];
nums.iter().for_each(|x| println!("{}", x));
```

---

## Iteratori Infiniti

### Range Aperti e `repeat`

```rust
use std::iter;

// Range infinito - SEMPRE limitare!
let first_10: Vec<i32> = (0..).take(10).collect();

// repeat
let fives: Vec<i32> = iter::repeat(5).take(3).collect();
assert_eq!(fives, vec![5, 5, 5]);

// repeat_with (con closure)
let randoms: Vec<i32> = iter::repeat_with(|| rand::random()).take(5).collect();
```

!!! danger "WARNING: Loop Infiniti"
    Metodi come `sum()`, `max()`, `collect()` senza `take()` su iteratori infiniti causano loop infiniti!

---

## Trait Speciali

### DoubleEndedIterator

Iteratori che possono andare avanti e indietro:

```rust
let nums = vec![1, 2, 3];
let mut iter = nums.iter();

assert_eq!(iter.next(), Some(&1));
assert_eq!(iter.next_back(), Some(&3));
assert_eq!(iter.next(), Some(&2));
```

### ExactSizeIterator

Iteratori con `len()` nota:

```rust
let nums = vec![1, 2, 3];
let iter = nums.iter();
assert_eq!(iter.len(), 3);
```

### FusedIterator

Garantisce `None` dopo il primo `None`:

```rust
let nums = vec![1, 2, 3];
let iter = nums.iter().fuse();
// Dopo None, continua a restituire None
```

---

## Creare Iteratori Custom

### Pattern Base

```rust
struct Counter {
    count: u32,
    max: u32,
}

impl Iterator for Counter {
    type Item = u32;

    fn next(&mut self) -> Option<Self::Item> {
        if self.count < self.max {
            self.count += 1;
            Some(self.count)
        } else {
            None
        }
    }
}

let counter = Counter { count: 0, max: 5 };
let nums: Vec<u32> = counter.collect();
assert_eq!(nums, vec![1, 2, 3, 4, 5]);
```

### Fibonacci Iterator

```rust
struct Fibonacci {
    curr: u32,
    next: u32,
}

impl Iterator for Fibonacci {
    type Item = u32;

    fn next(&mut self) -> Option<Self::Item> {
        let current = self.curr;
        self.curr = self.next;
        self.next = current + self.next;
        Some(current)
    }
}

let fib = Fibonacci { curr: 0, next: 1 };
let first_10: Vec<u32> = fib.take(10).collect();
assert_eq!(first_10, vec![0, 1, 1, 2, 3, 5, 8, 13, 21, 34]);
```

### Implementare IntoIterator

```rust
struct MyCollection {
    items: Vec<i32>,
}

impl IntoIterator for MyCollection {
    type Item = i32;
    type IntoIter = std::vec::IntoIter<i32>;

    fn into_iter(self) -> Self::IntoIter {
        self.items.into_iter()
    }
}

let coll = MyCollection { items: vec![1, 2, 3] };
for item in coll {
    println!("{}", item);
}
```

---

## Pattern e Best Practice

### Quando Usare Iteratori

✅ **Usa iteratori per**:

- Trasformazioni su collezioni
- Filtraggio dati
- Pipeline di elaborazione
- Operazioni funzionali

❌ **Evita iteratori quando**:

- Serve controllo fine del loop
- Necessari indici complessi
- La logica è più chiara con loop espliciti

### Performance

Gli iteratori in Rust sono **zero-cost abstractions**:

```rust
// Questi due hanno le stesse performance:
let sum1: i32 = (0..1000).sum();

let mut sum2 = 0;
for i in 0..1000 {
    sum2 += i;
}
```

### Errori Comuni

**1. Dimenticare di consumare adapter**:

```rust
// ❌ Non fa nulla!
vec.iter().map(|x| x * 2);

// ✅ Consuma con collect
let result: Vec<_> = vec.iter().map(|x| x * 2).collect();
```

**2. Usare nth() in loop** (O(n²)):

```rust
// ❌ Anti-pattern
for i in 0..vec.len() {
    vec.iter().nth(i);
}

// ✅ Usa direttamente l'iteratore
for item in vec.iter() {
    // ...
}
```

**3. Clone non necessari**:

```rust
// ❌ Clone inutile
vec.iter().map(|x| x.clone()).collect()

// ✅ Usa cloned()
vec.iter().cloned().collect()
```

---

## Esempi Pratici Complessi

### 1. Parsing CSV

```rust
let csv = "name,age\nAlice,30\nBob,25";
let people: Vec<(&str, i32)> = csv.lines()
    .skip(1) // Salta header
    .filter_map(|line| {
        let parts: Vec<&str> = line.split(',').collect();
        Some((parts.get(0)?, parts.get(1)?.parse().ok()?))
    })
    .collect();
```

### 2. Filtrare e Trasformare Log

```rust
let logs = vec![
    "[INFO] Application started",
    "[ERROR] Connection failed",
    "[INFO] Processing request",
    "[ERROR] Timeout occurred",
];

let errors: Vec<String> = logs.iter()
    .filter(|log| log.contains("[ERROR]"))
    .map(|log| log.replace("[ERROR] ", ""))
    .collect();
```

### 3. Raggruppamento Dati

```rust
use std::collections::HashMap;

let words = vec!["apple", "banana", "avocado", "blueberry", "apricot"];
let grouped: HashMap<char, Vec<&str>> = words.iter()
    .fold(HashMap::new(), |mut acc, word| {
        acc.entry(word.chars().next().unwrap())
            .or_insert_with(Vec::new)
            .push(word);
        acc
    });
```

### 4. Pipeline Multi-Stage

```rust
let text = "hello world from rust programming";
let result: String = text.split_whitespace()
    .filter(|w| w.len() > 4)
    .map(|w| w.to_uppercase())
    .enumerate()
    .map(|(i, w)| format!("{}. {}", i + 1, w))
    .collect::<Vec<_>>()
    .join(" | ");
```

### 5. Combinare Iteratori da Fonti Diverse

```rust
let file1_lines = vec!["line1", "line2"];
let file2_lines = vec!["line3", "line4"];
let prefix = vec!["header"];

let all_lines: Vec<&str> = prefix.iter()
    .chain(file1_lines.iter())
    .chain(file2_lines.iter())
    .cloned()
    .collect();
```

---

## Iteratori e Option/Result

### Collect con Result

```rust
let strings = vec!["1", "2", "3", "not a number"];
let result: Result<Vec<i32>, _> = strings.iter()
    .map(|s| s.parse::<i32>())
    .collect();

// collect fallisce al primo errore
assert!(result.is_err());
```

### filter_map con Option

```rust
let strings = vec!["1", "two", "3", "four"];
let numbers: Vec<i32> = strings.iter()
    .filter_map(|s| s.parse().ok())
    .collect();

assert_eq!(numbers, vec![1, 3]);
```

### Pattern con `?`

```rust
fn parse_numbers(strs: &[&str]) -> Result<Vec<i32>, std::num::ParseIntError> {
    strs.iter()
        .map(|s| s.parse::<i32>())
        .collect()
}
```

---

## Vedi Anche

- **[Collections](../collections/index.md)** - Introduzione rapida agli iteratori
- **[Vec](../collections/vec.md)** - Esempi di iterazione su Vec
- **[HashMap](../collections/hashmap.md)** - Iterazione su mappe
- **[String](../string/string.md)** - Iteratori chars() e bytes()

**Documentazione Ufficiale**:

- [std::iter Module](https://doc.rust-lang.org/std/iter/)
- [Iterator Trait](https://doc.rust-lang.org/std/iter/trait.Iterator.html)
- [IntoIterator Trait](https://doc.rust-lang.org/std/iter/trait.IntoIterator.html)

**Risorse Esterne**:

- [The Rust Book - Iterators](https://doc.rust-lang.org/book/ch13-02-iterators.html)
- [Rust by Example - Iterators](https://doc.rust-lang.org/rust-by-example/trait/iter.html)

---

!!! question "Hai trovato errori o imprecisioni?"
    Aiutaci a migliorare questa traduzione!
    [Apri una issue](https://github.com/rust-ita/rust-docs-it/issues)
    o proponi una modifica.
