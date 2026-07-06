# Konvexe Probleme

In diesem Abschnitt geht es darum ein besseres Verständnis zu geben über Algorithmen und Konzepte welche zum Beispiel bei der $2$d-/$3$d-Kollisionsdetektion oder in Optimierungs-Algorithmen genutzt werden. Die Erklärungen sind eine stärkere und vereinfachte Zusammenfassung aus [@nuetzig_thesis_2016, chap. 6].
Dieses Kapitel möchte nicht mathematisch abschliessend sein, sondern lediglich (nach der Ansicht des Autors) ein paar wichtige Grundkonzepte vermitteln, welche einen wunderbaren Einstieg in dieses Thema geben. Die erwähnten Konzepte sind in der generellsten Form der konvexen Analysis zu finden und können sehr wohl als die wichtigsten Standbeine verinnerlicht werden. Auf Beweise wird bewusst verzichtet. Es wird versucht die mathematischen Definitionen anschaulich zu erklären.

Das Vorhandensein eines *konvexen* Optimierungsproblems oder auch einer *konvexen Menge* beim Lösen eines Problems in $3$D, oder auch mehr Dimensionen, erlaubt es, auf eine Fülle von mathematisch sehr etablierten Definitionen und Konzepte aus der *konvexen Analysis* zurückzugreifen. Diese schon fast 50-jährige Theorie ist sehr fundiert und ein abgeschlossenes Untergebiet in der Mathematik.

Die *konvexe Analysis* ist ein Grenzgebiet von *Geometrie*, *Analysis* und *Funktionalanalysis*, das sich mit den Eigenschaften **konvexer Mengen** und **konvexer Funktionen** befaßt und Anwendungen sowohl in der reinen Mathematik besitzt (von Existenzsätzen in der Theorie der Differential- und Integralgleichungen bis zum Gitterpunktsatz von Minkowski in der Zahlentheorie) als auch in Bereichen wie der mathematischen Ökonomie und den Ingenieurswissenschaften, wo man es oft mit Optimierungs- und Gleichgewichtsproblemen zu tun hat. Als einschlägige Referenz auf diesem Gebiet sei hier mal das Standardwerk [@rockafellar_convex_2015] gegeben.

## Konvexe Menge

Eine Menge $\set{C} \subseteq V$, also ein Teilmenge eines Vektorraums $V$, wird **konvex** genannt, falls und nur falls
`\begin{align}
\lambda \vvec{a} + (1-\lambda) \vvec{b} \in \set{C} \quad \forall \vvec{a},\vvec{b} \in \set{C}, \ \lambda \in [0,1] \ .
\end{align}`{=latex}
gilt.

Das heisst alle Punkte auf einer geraden Linie zwischen zwei beliebigen Punkten aus der Menge $\set{C}$ müssen **auch** in dieser Menge liegen damit es **konvex** ist. Stellt man sich eine Banane vor oder eine Oberfläche eines $3$d-Würfels, dann erfüllen diese Mengen das Kriterium nicht. Ein ausgefülltes $2$d-Rechteck , ein gefüllter $3$d-Würfel oder eine gefüllte Kugel jedoch schon.
Eine **konvexe** Menge ist eine Teilmenge eines Vektorraums. Ein Beispiel ist der euklidische Raum $\mathbb{E}^3$ in $3$D.

Man interessiert sich nun zum Beispiel für die Projektion eines Punktes $\vvec{x}$ auf ein konvexe Menge $\set{C}$. Die Projektion sollte so sein, dass der Abstand zwischen dem Punkt $\vvec{x}$ und dem projezierten Punkt $\vvec{y} \in \set{C}$ **minimal** ist.

Der Abstand wird über eine Metrik $d(\vvec{x},\vvec{y}) \geq 0$ definiert - die *Distanzfunktion*. Der euklidische Vektorraum $\mathbb{E}^3$ ist ein Vektorraum mit einer Metrik und ist daher ein *metrischer Raum*. Das Standard-Skalarprodukt $\vvec{x}^\transp \vvec{y}$ im euklidischen Raum $\mathbb{E}^3$ induziert direkt die Standardnorm $\norm{\vvec{x}}_2 := \sqrt{\vvec{x}^\transp \vvec{x}} \geq 0$. Diese wiederum induziert direkt die Metrik
`\begin{align}
d(\vvec{x},\vvec{y}) := \norm{\vvec{x} - \vvec{y}}_2.
\end{align}`{=latex}

Wir können somit über die Metrik $d(\vvec{x},\vvec{y})$ die Länge zwischen zwei Vektoren $\vvec{x},\vvec{y} \in \mathbb{E}^3$ berechnen.

## Proximaler Punkt

Mit der Metrik, also unserem Lineal zum Messen von Distanzen, lässt sich nun die Projektion $\prox{C}(\vvec{p})$ eines Punktes $\vvec{p}$ mit minimaler Distanz auf eine konvexe Menge $\set{C}$ relativ leicht definieren zu
`\begin{align}
\prox{C}(\vvec{p}) :=  \underset{\vvec{x} \ \in \ \set{C}}{\argmin} \norm{\vvec{x} - \vvec{p}}_2.
\end{align}`{=latex}

Das heisst $\prox{C}(\vvec{p})$ minimiert den Punkt $\vvec{x}$ in der Menge $\set{C}$ so, dass sein Abstand zu $\vvec{p}$ minimal ist.

## Normalkegel

Eines der **wichtigsten** Konzept der konvexen Analysis ist die des **Normalkegels**. Wie der Name schon sagt, handelt es sich um einen Kegel welcher durch Normalenvektoren auf der Oberfläche einer konvexen Menge aufgespannt wird. Wir geben hier direkt die Definition und sehen im Anschluss wie sich dieser Kegel visualisiert:

Ein Normalkegel $\ncone{C}$ auf ein konvexes Set $\set{C}$ im Punkt $\vvec{x} \in \set{C}$ ist definert als
`\begin{align}
    \ncone{C}(\vvec{x}) := \left\{ \vvec{y} \ | \ \vvec{y}^\transp(\vvec{x}^* - \vvec{x}) \leq 0, \quad \forall \vvec{x}^* \in \set{C} \right\}
\end{align}`{=latex}

Das ist nun ein wenig kryptisch, heisst jedoch nichts anderes als folgendes:
Der Normalkegel $\ncone{C}(\vvec{x})$ besteht aus allen Vektoren (das wäre $\vvec{y}$) ausgehend von $\vvec{x}$ welche mit **allen** Vektoren welche vom Punkt $\vvec{x}$ in die Menge $\set{C}$ zeigen (das wäre $\vvec{x}^* - \vvec{x}$), einen **stumpfen** Winkel bilden (das wäre das Skalatprodukt mit $\leq 0$).
Der Ursprung der Menge $\ncone{C}(\vvec{x})$ ist im Punkt $\vvec{x}$.

Die Abbildung [-@fig:normalcone] visualisiert für eine konvexe Menge $\set{C}$ die verschiedenen Normalkegel.

![Normalkegel an die Punkte $\vvec{x}$, $\vvec{y}$ und $\vvec{z}$. Der Normalkegel an einen innerhalb der Menge $\set{C}$ liegenden Punkt $\vvec{z}$ degeneriert zum $\vvec{0}$-Vektor. Der Vektor $\vvec{v}$ ist in der Menge des Normalkegels an $\vvec{x}$.](files/NormalKegel.svg){#fig:normalcone style="width:100%;max-width:7cm"}

## Zusammenhang von Normalkegel und Proximaler Punkt

Man fragt sich natürlich nun: *Was bringen uns diese mathematische Definitionen?*

Es stellt sich heraus, dass es einen Zusammenhang gibt zwischen $\prox{C}$ und $\ncone{C}$ welcher extremst nützlich ist und heute im Feld der konvexen Optimierung, beim Machine-Learning, in der Starrkörper-Mechanik (Starrkörper-Simulationen und Physics-Engines in Games) oder auch in der Kollisionsdetektion (GJK Algorithmus) durch projektive Iterationen direkte Anwendung findet.

Der Zusammenhang ist wie folgt:
`\begin{align}
\vvec{y} \in \ncone{C}(\vvec{x}) \quad \Leftrightarrow \quad \vvec{x} = \prox{C}(\vvec{x} + \vvec{y})
\label{eq:prox-to-ncone}
\end{align}`{=latex}

Das heisst, eine Normalkegel-*Inklusion* (die Relation $\vvec{a} \in \set{B}$ wird *Mengen-Inklusion* genannt) ist direkt an eine **implizite** *projektive* Gleichung gekoppelt.

Damit lässt sich nun ein interessanter wichtiget Fakt ableiten.
Aus der Visualisierung [-@fig:normalcone] entnehmen wir, dass $\vvec{p}-\vvec{x}$ in der Menge $\ncone{C}(\vvec{x})$ liegt, also lässt sich schreiben
`\begin{align}
\vvec{p}-\vvec{x} \in \ncone{C}(\vvec{x}).
\end{align}`{=latex}

Dies lässt sich mit obiger Beziehung direkt zu
`\begin{align}
\vvec{x} &= \prox{C}(\vvec{x} + \vvec{p} - \vvec{x}) \\
&= \prox{C}(\vvec{p}).
\end{align}`{=latex}
umschreiben. Aus dem erkennen wir, dass der Ursprung des Normalkegels, worin ein **beliebiger** Punkt $\vvec{p}$ liegt, direkt der **proximale** Punkt ist zu $\vvec{p}$.

Müssten wir nun eine Projektionsfunktion auf ein $2$d-Dreieck herleiten, würden wir folgendes Bild malen:

![Normalkegel an die Punkte $\vvec{a}$, $\vvec{b}$ und $\vvec{c}$ eines Dreiecks.](files/NormalKegelDreieck.svg){#fig:normalconetri style="width:100%;max-width:7cm"}

Das heisst es gibt genau 3 nicht triviale Normalkegel und 3 einfachere Normalkegel (bestehend lediglich aus den Normalen auf die Seitenflächen). Eine Projektionsfunktion auf ein Dreieck muss diese 6 Bereiche beachten und ist so auch optimal und richtig implementiert.

## Zusammenhang von Normalkegel und Konvexer Optimierung

Um hier mathematisch nicht in einen Exzess zu geraten, wird hier nur eine abgespeckte Erklärung gegeben. Für mehr Informationen sei auf [@nuetzig_thesis_2016, chap. 6] verwiesen und die darin enthaltenen Referenzen.

Betrachte man folgendes allgemeine restriktierte **konvexe** Optimierungsproblem:
`\begin{align}
\vvec{x}^* = \underset{\vvec{x} \ \in \ \set{C}}{\argmin} f(\vvec{x}),
\label{eq:convexproblem}
\end{align}`{=latex}
wobei die Funktion $f(\vvec{x}) \in \mathbb{R}$ **strikt konvex** und **differenzierbar** (man stelle sich den oberen Teil eines Weinglases vor, wobei $\vvec{x} \in \mathbb{R}^2$) ist und die minimierenden Punkte $\vvec{x}$ auf eine **konvexe** Menge $\set{C}$ restriktiert sind. Der minimierende Punkt ist hier mit $\vvec{x}^*$ bezeichnet. Es gibt nur **einen** solchen globalen minimierenden Punkt

Dann kann man das Problem in ein freies **konvexes** Programm umschreiben indem man die Einschränkung $\vvec{x} \in \set{C}$ mit einer Bestrafungsfunktion $\indf{C}(\vvec{x})$ ersetzt
`\begin{align}
\vvec{x}^* = \underset{\vvec{x}}{\argmin} f(\vvec{x}) + \indf{C}(\vvec{x}).
\end{align}`{=latex}

Die Bestrafungsfunktion $\indf{C}(\vvec{x})$ liefert $0$ falls $\vvec{x} \in \set{C}$ und sonst $+\infty$. Diese Funktion wird **Indikatorfunktion** genannt.

Die Frage ist nun wie kriegen wir eine Bedingung an den optimalen (minimierenden) Punkt $\vvec{x}^*$.
Das geht ziemlich analog zu der Bedindung für Minima/Maxima einer differenzierbaren Funktionen $f$ :
`\begin{align}
\vvec{0} = \frac{df}{d\vvec{x}}(\vvec{x}^*)
\label{eq:optimality-difffunc}
\end{align}`{=latex}
was konkret heisst, dass der Nullvektor $\vvec{0}$ gleich dem Gradient $\frac{df}{d\vvec{x}}$ ist an der optimalen Stelle $\vvec{x}^*$.

Da wir aber bei unserem Problem $\eqref{eq:convexproblem}$ diese **unstetige**, **nicht-differenzierbare** Bestrafungsfunktion $\indf{C}$ eingebaut haben, ist dies nicht direkt mit der normalen Differentiation zu machen. Man braucht in der konvexen Analysis eine verallgemeinerte Ableitung - das **Subdifferential**, welches nicht mehr nur einfache Steigungen (d.h. die Steigung für $1$-dimensionale Funktionen $f(x)$ oder allgemeiner der Gradient für $n$-dimensionale Funktionen $f(\vvec{x})$) zurück geben kann sondern auch **ganze Mengen** von solchen Steigungen. Das heisst, das Subdifferential an einem Punkt ist eine Menge aller Gradienten an diesen Punkt der Funktion.
Das heisst direkt, dass eine Gleicheit zu $\vvec{0}$ wie in $\eqref{eq:optimality-difffunc}$ nicht mehr richtig wäre und hier eine Mengen-Inklusion $\vvec{0} \in \dots$ stehen muss.

Anstatt $\frac{d}{d\vvec{x}}\indf{C}$ nehmen wir einfach das Subdifferential $\partial_{\vvec{x}} \indf{C}$ und die Bedingung $\eqref{eq:optimality-difffunc}$ wird dann zu
`\begin{align}
\label{eq:optimality-strict-convex}
\vvec{0} \in \frac{df}{d\vvec{x}}(\vvec{x}^*) + \partial_{\vvec{x}} \indf{C}(\vvec{x}^*)
\end{align}`{=latex}

Nur was machen wir nun mit dieser **mengenwertigen Relation**?

Da man zeigen kann, dass das Subdifferential, also die mengenwertige Ableitung, der Indikatorfunktion $\partial_{\vvec{x}} \indf{C}(\vvec{x})$ genau dem Normalkegel $\ncone{C}(\vvec{x})$ entspricht, können wir die obige Inklusion so schreiben:
`\begin{align}
\vvec{0} \in \frac{df}{d\vvec{x}}(\vvec{x}^*) + \ncone{C}(\vvec{x}^*) \quad \Leftrightarrow \quad -\frac{df}{d\vvec{x}}(\vvec{x}^*) \in \ncone{C}(\vvec{x}^*)
\label{eq:optimality-strict-convex-2}
\end{align}`{=latex}

Das bringt uns nicht viel mehr ausser einer visuellen Erkenntnis durch folgende Visualisierung:

![Konvexes Optimierungs Problem innerhalb der Menge $\set{C}$ auf einer $2$d-Funktion $f(\vvec{x}) \in \mathbb{R}$. Der negative Gradient liegt im Optimum $\vvec{x}^*$ genau innerhalb des Normalkegels an $\vvec{x}^*$.](files/ConvexOptimizationProblem.svg){#fig:convex-opt-prob style="width:100%;max-width:100%"}

Mit der Beziehung zwischen **proximalem Punkt** und **Normalkegel** $\eqref{eq:prox-to-ncone}$ kriegen wir daraus direkt eine **implizite Projektionsgleichung** für den optimalen Punkt $\vvec{x}^*$:
`\begin{align}
-\frac{df}{d\vvec{x}}(\vvec{x}^*) \in \ncone{C}(\vvec{x}^*) \quad \Leftrightarrow \quad \vvec{x}^* = \prox{C}(\vvec{x}^* - \frac{df}{d\vvec{x}}(\vvec{x}^*)),
\end{align}`{=latex}
welche man iterative lösen kann, was zum **Gradienten-Projektionsverfahren** führt (Gradient Projection Algorithm).
