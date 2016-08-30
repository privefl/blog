---
title:  "R package primefactr"
author: "Florian Privé"
date: "August 10, 2016"
layout: post
---



<section class="main-content">
<p>In this post, I will present my first R package, <a href="https://cran.r-project.org/web/packages/primefactr/index.html">available on CRAN</a>. It makes use of <a href="https://en.wikipedia.org/wiki/Prime_factor">Prime Factorization</a> for computations.</p>
<p>This small R package was initially developed to compute <a href="https://en.wikipedia.org/wiki/Hypergeometric_distribution">hypergeometric probabilities</a> which are used in Fisher’s exact test, for instance. It was also a way to get introduced with CRAN submission :’).</p>
<div id="installation-and-attachment" class="section level2">
<h2>Installation and Attachment</h2>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">## Installation
<span class="kw">install.packages</span>(<span class="st">&quot;primefactr&quot;</span>)</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">## Attachment
<span class="kw">library</span>(<span class="st">&quot;primefactr&quot;</span>)</code></pre></div>
</div>
<div id="features" class="section level2">
<h2>Features</h2>
<div id="main-feature" class="section level3">
<h3>Main feature</h3>
<p>For instance, to compute <span class="math display">\[P(X = k) = \dfrac{\binom{K}{k}~\binom{N-K}{n-k}}{\binom{N}{n}} = \dfrac{K!~(N-K)!~n!~(N-n)!}{k!~(K-k)!~(n-k)!~(N-K-n+k)!~N!},\]</span> you can use</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">f &lt;-<span class="st"> </span>function(k, N, K, n) {
  <span class="kw">ComputeDivFact</span>(<span class="kw">c</span>(K, (N-K), n, (N-n)),
                 <span class="kw">c</span>(k, (K-k), (n-k), (N-K-n+k), N))
}
<span class="kw">f</span>(<span class="dv">4</span>, <span class="dv">50</span>, <span class="dv">5</span>, <span class="dv">10</span>)</code></pre></div>
<pre><code>## [1] 0.003964583</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">f</span>(<span class="dv">5</span>, <span class="dv">50</span>, <span class="dv">5</span>, <span class="dv">10</span>)</code></pre></div>
<pre><code>## [1] 0.0001189375</code></pre>
<p>You can check the results <a href="https://en.wikipedia.org/wiki/Hypergeometric_distribution#Application_and_example">here</a>.</p>
<p>Let us now check large numbers:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">f</span>(<span class="dt">k =</span> <span class="dv">1000</span>, <span class="dt">N =</span> <span class="dv">15100</span>, <span class="dt">K =</span> <span class="dv">5000</span>, <span class="dt">n =</span> <span class="dv">3100</span>)</code></pre></div>
<pre><code>## [1] 0.009003809</code></pre>
<p>A direct approach would require computing <code>factorial(15100)</code>, while <code>factorial(100) = 9.332622e+157</code>.</p>
</div>
<div id="implementation" class="section level3">
<h3>Implementation</h3>
<p>This uses a Prime Factorization to simplify computations.</p>
<p>I code a number as follows, <span class="math display">\[number = \prod i^{code[i]},\]</span> or, which is equivalent, <span class="math display">\[\log(number) = \sum code[i] \times \log(i).\]</span> For example,</p>
<ul>
<li><span class="math inline">\(5\)</span> is coded as (0, 0, 0, 0, 1),</li>
<li><span class="math inline">\(5!\)</span> is coded as (1, 1, 1, 1, 1),</li>
<li><span class="math inline">\(8!\)</span> is coded as (1, 1, 1, 1, 1, 1, 1, 1).</li>
</ul>
<p>So, to compute <span class="math inline">\(8! / 5!\)</span>, you just have to substract the code of <span class="math inline">\(5!\)</span> from the code of <span class="math inline">\(8!\)</span> which gives you (0, 0, 0, 0, 0, 1, 1, 1).</p>
<p>Then there is the step of Prime Factorization:</p>
<p>Factorization by 2:</p>
<ul>
<li>it becomes (0, 2, 1, 1, 0, 0, 1, 0) because <span class="math inline">\(8 = 4 \times 2\)</span> and <span class="math inline">\(6 = 3 \times 2\)</span>,</li>
<li>then it becomes (0, 4, 1, 0, 0, 0, 1, 0) because <span class="math inline">\(4 = 2^2\)</span>.</li>
</ul>
<p>This is already finished (this is a small example). You get that <span class="math inline">\(8! / 5! = 2^4 \times 3^1 \times 7^1\)</span>. Let us verify:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">cat</span>(<span class="kw">sprintf</span>(<span class="st">&quot;%s == %s&quot;</span>, <span class="kw">factorial</span>(<span class="dv">8</span>) /<span class="st"> </span><span class="kw">factorial</span>(<span class="dv">5</span>), <span class="dv">2</span>^<span class="dv">4</span> *<span class="st"> </span><span class="dv">3</span> *<span class="st"> </span><span class="dv">7</span>))</code></pre></div>
<pre><code>## 336 == 336</code></pre>
</div>
<div id="play-with-primes" class="section level3">
<h3>Play with primes</h3>
<p>You can also test if a number is a prime and get all prime numbers up to a certain number.</p>
</div>
</div>
<div id="submission-to-cran" class="section level2">
<h2>Submission to CRAN</h2>
<p>It was easier than I thought. I’ve just followed the instructions of the book <a href="http://r-pkgs.had.co.nz/">R packages</a> by Hadley Wickham. I had two notes:</p>
<ol style="list-style-type: decimal">
<li>It is my first submission.</li>
<li>File README.md cannot be checked without ‘pandoc’ being installed. For this note, I used the same comment as <a href="https://github.com/klarsen1/Information/blob/b3a826a6f8a38aa8c664156cef4f16edae196ec3/cran-comments.md#r-cmd-check-results">here</a> and CRAN didn’t complain.</li>
</ol>
</div>
</section>
