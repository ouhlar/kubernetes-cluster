# PROSTREDIE NA ORCHESTRÁCIU KONTAJNEROV NA UNIVERZITE

Tento README.md dokument poskytuje návod na lokálne nasadenie Kubernetes klastra pre účely univerzitnej infraštruktúry. Skript definovaný v jazyku Ruby s využitím nástroja Vagrant slúži na automatizované nastavenie virtuálnych strojov (VM), ktoré budú fungovať ako uzly Kubernetes klastra.

## Nasadenie Kubernetes klastra

Proces nasadenia Kubernetes klastra je kľúčový pre úspešné vytvorenie robustného a flexibilného prostredia na orchestáciu kontajnerov. Nasledujúce kroky poskytujú návod na zriadenie klastra, od základných požiadaviek až po spustenie a prístup k uzlom.

### Požiadavky

Enviroment:

- Virtualbox 7.0.6
- Vagrant 2.4.1
- Ruby

Minimálne požiadavky pre uzly:

- 2 CPU
- 2 GB RAM
- 2 GB voľného miesta na disku

### Konfigurácia

Všetky špecifikácie virtuálnych strojov sú načítané z externého YAML súboru vagrant_config.yaml. Súbor by mal obsahovať konfigurácie, ako sú počet master a worker uzlov, ich hardvérové špecifikácie, IP adresy a skripty potrebné na ich nastavenie.

### Inštalácia a Spustenie

1. Nainštalujte všetky potrebné závislosti (Vagrant, VirtualBox, Ruby).
2. Naklonujte tento repozitár alebo stiahnite Vagrant skript a príslušný vagrant_config.yaml konfiguračný súbor.
3. Otvorte terminál a navigujte do priečinku obsahujúceho `Vagrantfile`.
4. Spustite nasledujúce príkazy pre inicializáciu a spustenie virtuálnych strojov:

    ```bash
    vagrant up
    ```

    Tento príkaz postupne spustí a nakonfiguruje všetky definované VM ako uzly Kubernetes klastra podľa nastavení v YAML konfiguračnom súbore.
5. Po úspešnom spustení klastra môžete pristupovať k jednotlivým uzlom pomocou príkazu:

    ```bash
    vagrant ssh <nazov_uzla>
    ```

## Deployment študentského kontajnera

Časť infraštruktúry je tiež možné využiť na nasadzovanie študentských kontajnerov, ktoré môžu byť použité pre výukové účely alebo individuálne projekty. Nasledujúca sekcia poskytuje príklad Deployment a Service konfigurácií pre Kubernetes, ktoré umožňujú spustiť a sprístupniť študentský kontajner.

### Deployment konfigurácia

Súbor deployment.yaml definuje Kubernetes Deployment, ktorý automatizuje nasadenie a riadenie študentských kontajnerov. Tento konfiguračný súbor vytvára nasadenie s jednou replikou kontajnera `uhlaro/student_container:latest`. Kontajner bude mať otvorený port 22, ktorý je štandardne používaný pre SSH (Secure Shell) spojenia.

### Service konfigurácia

Súbor expose_ssh_service.yaml definuje Kubernetes Service, ktorý umožňuje pristupovať k SSH portu nasadeného kontajnera z vonkajšej siete. Service vytvára NodePort, ktorý sprístupní SSH port na klastri, umožňujúc študentom pripojiť sa na svoje kontajnery z vonkajšej siete.

### Postup nasadenia

1. Pripravte Kubernetes klaster podľa predchádzajúcich krokov v tomto dokumente.
2. Uložte vyššie uvedené konfiguračné súbory (deployment.yaml a expose_ssh_service.yaml) do pracovného priečinka.
3. Aplikujte konfigurácie v klastri použitím kubectl príkazov:

    ```bash
    kubectl apply -f deployment.yaml
    kubectl apply -f expose_ssh_service.yaml
    ```

4. Skontrolujte stav nasadených zdrojov:

    ```bash
    kubectl get pods
    kubectl get services
    ```

5. Zistite, na ktorom NodePorte je SSH služba dostupná:

    ```bash
    kubectl get service student-container-service
    ```

6. Použite príslušný NodePort a IP adresu pracovného uzla klastra na pripojenie k študentskému kontajneru cez SSH.

7. Na vzdialené pripojenie k študentskému kontajneru cez SSH použite príkaz v nasledujúcom formáte, pričom `<Node_IP>` nahraďte IP adresou pracovného uzla klastra a `<NodePort>` nahraďte NodePortom, ktorý bol pridelený vašej službe (získate ho pomocou predchádzajúceho kubectl get service príkazu). Pri lokálnom nasadení je potrebne ešte pridať presmerovanie portov v sieťových nastaveniach pracovného uzla.

    ```bash
    ssh -p <NodePort> user@<Node_IP>
    ```

### Dodatočné informácie

- Ak chcete škálovať nasadenie a umožniť viac študentom používať kontajnery, zmeňte hodnotu replicas v deployment.yaml súbore.
- Pre zabezpečenie prístupu môžete konfigurovať autentifikáciu pomocou SSH kľúčov namiesto hesiel.
- Aby boli kontajnery dostupné na štandardnom SSH porte (22), môžete použiť LoadBalancer službu, ak je k dispozícii, alebo nastaviť reverzné proxy pravidlá na univerzitnom firewalli alebo routeri.

### Čistenie prostredia

Po skončení práce alebo ak chcete odstrániť nasadené zdroje, použite nasledujúce príkazy:

```bash
kubectl delete service student-container-service
kubectl delete deployment deployment-example
```

Tieto príkazy odstránia službu a nasadenie študentského kontajnera, čím uvoľnia zdroje na klastri pre iné účely.

Pre lokálne Kubernetes klastry nasadené s použitím Vagrantu, môžete tiež vyčistiť virtuálne stroje spustením:

```bash
vagrant destroy -f
```

Tento príkaz vypne a zničí všetky virtuálne stroje vytvorené pomocou Vagrantu, čím efektívne vyčistí vaše lokálne prostredie bez nutnosti potvrdzovania.
