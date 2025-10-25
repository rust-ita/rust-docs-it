# Collections

!!! info "Riferimento originale"
    📖 [Documentazione originale](https://doc.rust-lang.org/std/collections/)
    🔄 Traduzione in corso
    📝 Versione Rust: 1.90+

Le **collections** di Rust sono strutture dati che possono contenere valori multipli. A differenza degli array, i dati delle collection sono allocati sullo heap, il che significa che la quantità di dati non deve essere nota a compile-time e può crescere o ridursi durante l'esecuzione del programma.

---

## 📚 Collections Disponibili

### ✅ Tradotte

- **[Vec\<T\>](vec.md)** - Array dinamico ridimensionabile
  - Crescita/riduzione dinamica
  - Accesso per indice O(1)
  - Push/pop O(1) ammortizzato
  - [Vai alla documentazione →](vec.md)

### 📅 Prossimamente

Le seguenti collections verranno tradotte prossimamente:

#### HashMap\<K, V\>
Mappa hash per coppie chiave-valore con accesso O(1) medio.

🔗 [Documentazione ufficiale (EN)](https://doc.rust-lang.org/std/collections/struct.HashMap.html)

#### HashSet\<T\>
Set basato su hash per valori unici con accesso O(1) medio.

🔗 [Documentazione ufficiale (EN)](https://doc.rust-lang.org/std/collections/struct.HashSet.html)

#### BTreeMap\<K, V\>
Mappa ordinata basata su B-tree con accesso O(log n).

🔗 [Documentazione ufficiale (EN)](https://doc.rust-lang.org/std/collections/struct.BTreeMap.html)

#### BTreeSet\<T\>
Set ordinato basato su B-tree con accesso O(log n).

🔗 [Documentazione ufficiale (EN)](https://doc.rust-lang.org/std/collections/struct.BTreeSet.html)

#### VecDeque\<T\>
Coda double-ended per inserimento/rimozione efficiente da entrambi i lati.

🔗 [Documentazione ufficiale (EN)](https://doc.rust-lang.org/std/collections/struct.VecDeque.html)

#### LinkedList\<T\>
Lista doppiamente concatenata (raramente usata, preferire Vec o VecDeque).

🔗 [Documentazione ufficiale (EN)](https://doc.rust-lang.org/std/collections/struct.LinkedList.html)

#### BinaryHeap\<T\>
Heap binario (coda di priorità).

🔗 [Documentazione ufficiale (EN)](https://doc.rust-lang.org/std/collections/struct.BinaryHeap.html)

---

## 🎯 Quale Collection Usare?

### Guida Rapida

```mermaid
graph TD
    A[Hai bisogno di una collection?] --> B{Tipo di dati}
    B -->|Sequenza ordinata| C{Dimensione nota?}
    B -->|Coppie chiave-valore| D{Serve ordinamento?}
    B -->|Valori unici| E{Serve ordinamento?}

    C -->|Sì| F[Array]
    C -->|No| G[Vec]

    D -->|No| H[HashMap]
    D -->|Sì| I[BTreeMap]

    E -->|No| J[HashSet]
    E -->|Sì| K[BTreeSet]
```

### Usa Vec quando:
- ✅ Vuoi una sequenza di elementi
- ✅ Serve accesso per indice
- ✅ Aggiungi/rimuovi principalmente alla fine
- ✅ È la collection più comune (usa questa di default)

### Usa HashMap quando:
- ✅ Vuoi associare chiavi a valori
- ✅ Serve accesso veloce per chiave
- ✅ L'ordine non è importante

### Usa HashSet quando:
- ✅ Vuoi memorizzare valori unici
- ✅ Serve verificare se un elemento esiste
- ✅ L'ordine non è importante

### Usa BTreeMap/BTreeSet quando:
- ✅ Serve iterare in ordine ordinato
- ✅ Serve trovare il min/max efficiente
- ✅ Serve range query

### Usa VecDeque quando:
- ✅ Inserisci/rimuovi da entrambi i lati
- ✅ Implementi una coda o stack

---

### Performance
Per scegliere la raccolta giusta per il lavoro è necessario comprendere i punti di forza di ciascuna collection. Di seguito riassumiamo brevemente le prestazioni delle diverse collection per alcune operazioni importanti. Per ulteriori dettagli, consultare la documentazione relativa a ciascun tipo e tenere presente che i nomi dei metodi effettivi potrebbero differire da quelli riportati nelle tabelle sottostanti per alcune raccolte.

In tutta la documentazione, ci atterremo alle seguenti convenzioni per la notazione delle operazioni:
  - La dimensione della collection è indicata con n.
  - Se è coinvolta una seconda collection, la sua dimensione è indicata con m.
  - Gli indici degli elementi sono indicati con i.
  - Le operazioni che hanno un costo ammortizzato sono contrassegnate dal suffisso *.
  - Le operazioni con un costo previsto sono contrassegnate dal suffisso ~.

La chiamata di operazioni che aggiungono elementi a una collection richiederà occasionalmente il ridimensionamento di essa, un'operazione aggiuntiva che richiede un tempo O(n).

I costi ammortizzati sono calcolati per tenere conto del costo in termini di tempo di tali operazioni di ridimensionamento su una serie sufficientemente ampia di operazioni. Una singola operazione può essere più lenta o più veloce a causa della natura sporadica del ridimensionamento della collection, tuttavia il costo medio per operazione si avvicinerà al costo ammortizzato.

Le raccolte di Rust non si riducono mai automaticamente, quindi sle operazioni di rimozione non sono ammortizzate.
HashMap utilizza i costi previsti. È teoricamente possibile, anche se molto improbabile, che HashMap abbia prestazioni significativamente peggiori rispetto al costo previsto. Ciò è dovuto alla natura probabilistica dell'hashing, ovvero è possibile generare un hash duplicato dato un determinato input chiave che richiederà un calcolo aggiuntivo per essere corretto.

#### Costo delle operazioni riassunto

| Struttura     | get(i)           | insert(i)              | remove(i)              | append(Vec(m)) | split_off(i)        | range        | append     |
|----------------|------------------|-------------------------|------------------------|----------------|---------------------|--------------|-------------|
| **Vec**        | O(1)             | O(n−i)\*               | O(n−i)                 | O(m)\*         | O(n−i)              | N/A          | N/A         |
| **VecDeque**   | O(1)             | O(min(i, n−i))\*       | O(min(i, n−i))         | O(m)\*         | O(min(i, n−i))      | N/A          | N/A         |
| **LinkedList** | O(min(i, n−i))   | O(min(i, n−i))         | O(min(i, n−i))         | O(1)           | O(min(i, n−i))      | N/A          | N/A         |
| **HashMap**    | O(1)~            | O(1)~\*                | O(1)~                  | N/A            | N/A                 | N/A          | N/A         |
| **BTreeMap**   | O(log n)         | O(log n)               | O(log n)               | N/A            | N/A                 | O(log n)     | O(n+m)      |

!!! note
    Si noti che in caso di parità, Vec sarà generalmente più veloce di VecDeque, mentre VecDeque sarà generalmente più veloce di LinkedList.
    Per gli insiemi, tutte le operazioni hanno lo stesso costo delle operazioni equivalenti su Map.


---

## 🤝 Vuoi Contribuire?

Vuoi aiutarci a tradurre HashMap, HashSet o altre collections?

[**Inizia a contribuire →**](../../CONTRIBUTING.md){ .md-button .md-button--primary }

---

## 📖 Risorse Aggiuntive

### Documentazione Ufficiale (Inglese)
- [Collections Module](https://doc.rust-lang.org/std/collections/)
- [The Book - Collections](https://doc.rust-lang.org/book/ch08-00-common-collections.html)
- [Rust by Example - Vec](https://doc.rust-lang.org/rust-by-example/std/vec.html)

### Performance
- [std::collections Performance](https://doc.rust-lang.org/std/collections/#performance)
- [Big-O Cheat Sheet](https://www.bigocheatsheet.com/)

---

**Ultima revisione**: Ottobre 2025
**Versione Rust**: 1.90+

*Documentazione originale © The Rust Project Developers | Traduzione © Rust Italia Community*
