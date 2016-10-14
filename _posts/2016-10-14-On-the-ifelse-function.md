---
title: "On the ifelse function"
author: "Florian Privé"
date: "October 15, 2016" # DO NOT USE Sys.Date()
layout: post
---



<section class="main-content">
<p>In this post, I will talk about the <a href="https://stat.ethz.ch/R-manual/R-devel/library/base/html/ifelse.html"><strong>ifelse</strong> function</a>, which behaviour can be easily misunderstood, as pointed out in <a href="http://stackoverflow.com/questions/40026975/subsetting-with-negative-indices-best-practices">my latest question on SO</a>. I will try to show how it can be used, and misued. We will also check if it is as fast as we could expect from a vectorized base function of R.</p>
<div id="how-can-it-be-used" class="section level2">
<h2>How can it be used?</h2>
<p>The first example comes directly from the R documentation:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">x &lt;-<span class="st"> </span><span class="kw">c</span>(<span class="dv">6</span>:-<span class="dv">4</span>)
<span class="kw">sqrt</span>(x)  <span class="co">#- gives warning</span></code></pre></div>
<pre><code>## Warning in sqrt(x): NaNs produced</code></pre>
<pre><code>##  [1] 2.449490 2.236068 2.000000 1.732051 1.414214 1.000000 0.000000      NaN      NaN
## [10]      NaN      NaN</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">sqrt</span>(<span class="kw">ifelse</span>(x &gt;=<span class="st"> </span><span class="dv">0</span>, x, <span class="ot">NA</span>))  <span class="co"># no warning</span></code></pre></div>
<pre><code>##  [1] 2.449490 2.236068 2.000000 1.732051 1.414214 1.000000 0.000000       NA       NA
## [10]       NA       NA</code></pre>
<p>So, it can be used, for instance, to handle special cases, in a vectorized, succinct way.</p>
<p>The second example comes from the <a href="https://cran.r-project.org/web/packages/Rcpp/vignettes/Rcpp-sugar.pdf">vignette of Rcpp Sugar</a>:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">foo &lt;-<span class="st"> </span>function(x, y) {
  <span class="kw">ifelse</span>(x &lt;<span class="st"> </span>y, x*x, -(y*y))
}
<span class="kw">foo</span>(<span class="dv">1</span>:<span class="dv">5</span>, <span class="dv">5</span>:<span class="dv">1</span>)</code></pre></div>
<pre><code>## [1]  1  4 -9 -4 -1</code></pre>
<p>So, it can be used to construct a vector, by doing an element-wise comparison of two vectors, and specifying a custom output for each comparison.</p>
<p>A last example, just for the pleasure:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">(a &lt;-<span class="st"> </span><span class="kw">matrix</span>(<span class="dv">1</span>:<span class="dv">9</span>, <span class="dv">3</span>, <span class="dv">3</span>))</code></pre></div>
<pre><code>##      [,1] [,2] [,3]
## [1,]    1    4    7
## [2,]    2    5    8
## [3,]    3    6    9</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">ifelse</span>(a %%<span class="st"> </span><span class="dv">2</span> ==<span class="st"> </span><span class="dv">0</span>, a, <span class="dv">0</span>)</code></pre></div>
<pre><code>##      [,1] [,2] [,3]
## [1,]    0    4    0
## [2,]    2    0    8
## [3,]    0    6    0</code></pre>
</div>
<div id="how-can-it-be-misused" class="section level2">
<h2>How can it be misused?</h2>
<p>I think many people think they can use <code>ifelse</code> as a shorter way of writing an <code>if-then-else</code> statement (this is a mistake I made). For example, I use:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">legend.pos &lt;-<span class="st"> </span><span class="kw">ifelse</span>(is.top, <span class="kw">ifelse</span>(is.right, <span class="st">&quot;topright&quot;</span>, <span class="st">&quot;topleft&quot;</span>),
                     <span class="kw">ifelse</span>(is.right, <span class="st">&quot;bottomright&quot;</span>, <span class="st">&quot;bottomleft&quot;</span>))</code></pre></div>
<p>instead of:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">if (is.top) {
  if (is.right) {
    legend.pos &lt;-<span class="st"> &quot;topright&quot;</span>
  } else {
    legend.pos &lt;-<span class="st"> &quot;topleft&quot;</span>
  }
} else {
  if (is.right) {
    legend.pos &lt;-<span class="st"> &quot;bottomright&quot;</span>
  } else {
    legend.pos &lt;-<span class="st"> &quot;bottomleft&quot;</span>
  }
}</code></pre></div>
<p>That works, but this doesn’t:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">ifelse</span>(<span class="ot">FALSE</span>, <span class="dv">0</span>, <span class="dv">1</span>:<span class="dv">5</span>)</code></pre></div>
<pre><code>## [1] 1</code></pre>
<p>Indeed, if you read carefully the R documentation, you see that <code>ifelse</code> is returning a vector of the same length and attributes as the condition (here, of length 1).</p>
<p>If you really want to use a more succinct notation, you could use</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="st">`</span><span class="dt">if</span><span class="st">`</span>(<span class="ot">FALSE</span>, <span class="dv">0</span>, <span class="dv">1</span>:<span class="dv">5</span>)</code></pre></div>
<pre><code>## [1] 1 2 3 4 5</code></pre>
<p>If you’re not familiar with this notation, I suggest you read <a href="http://adv-r.had.co.nz/Functions.html">the chapter about functions in book <em>Advanced R</em></a>.</p>
</div>
<div id="benchmarks" class="section level2">
<h2>Benchmarks</h2>
<div id="reimplementing-abs" class="section level3">
<h3>Reimplementing ‘abs’</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">abs2 &lt;-<span class="st"> </span>function(x) {
  <span class="kw">ifelse</span>(x &lt;<span class="st"> </span><span class="dv">0</span>, -x, x)
}
<span class="kw">abs2</span>(-<span class="dv">5</span>:<span class="dv">5</span>)</code></pre></div>
<pre><code>##  [1] 5 4 3 2 1 0 1 2 3 4 5</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">library</span>(microbenchmark)
x &lt;-<span class="st"> </span><span class="kw">rnorm</span>(<span class="fl">1e4</span>)

<span class="kw">print</span>(<span class="kw">microbenchmark</span>(
  <span class="kw">abs</span>(x), 
  <span class="kw">abs2</span>(x)
))</code></pre></div>
<pre><code>## Unit: microseconds
##     expr     min       lq       mean   median      uq       max neval
##   abs(x)   3.973   5.2975   36.19779   6.9530   9.271  1613.386   100
##  abs2(x) 496.299 523.9450 1595.51016 549.7695 634.859 80076.957   100</code></pre>
</div>
<div id="comparing-with-c" class="section level3">
<h3>Comparing with C++</h3>
<p>Consider the Rcpp Sugar example again, 4 means to compute it:</p>
<div class="sourceCode"><pre class="sourceCode cpp"><code class="sourceCode cpp"><span class="ot">#include &lt;Rcpp.h&gt;</span>
<span class="kw">using</span> <span class="kw">namespace</span> Rcpp;

<span class="co">// [[Rcpp::export]]</span>
NumericVector fooRcpp(<span class="dt">const</span> NumericVector&amp; x, <span class="dt">const</span> NumericVector&amp; y) {
  <span class="dt">int</span> n = x.size();
  NumericVector res(n);
  <span class="dt">double</span> x_, y_;
  <span class="kw">for</span> (<span class="dt">int</span> i = <span class="dv">0</span>; i &lt; n; i++) { 
    x_ = x[i];
    y_ = y[i];
    <span class="kw">if</span> (x_ &lt; y_) {
      res[i] = x_*x_;
    } <span class="kw">else</span> {
      res[i] = -(y_*y_);
    }
  }
  <span class="kw">return</span> res;
}</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">fooRcpp</span>(<span class="dv">1</span>:<span class="dv">5</span>, <span class="dv">5</span>:<span class="dv">1</span>)</code></pre></div>
<pre><code>## [1]  1  4 -9 -4 -1</code></pre>
<div class="sourceCode"><pre class="sourceCode cpp"><code class="sourceCode cpp"><span class="ot">#include &lt;Rcpp.h&gt;</span>
<span class="kw">using</span> <span class="kw">namespace</span> Rcpp;

<span class="co">// [[Rcpp::export]]</span>
NumericVector fooRcppSugar(<span class="dt">const</span> NumericVector&amp; x, 
                           <span class="dt">const</span> NumericVector&amp; y) {
  <span class="kw">return</span> ifelse(x &lt; y, x*x, -(y*y));
}</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">fooRcppSugar</span>(<span class="dv">1</span>:<span class="dv">5</span>, <span class="dv">5</span>:<span class="dv">1</span>)</code></pre></div>
<pre><code>## [1]  1  4 -9 -4 -1</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">foo2 &lt;-<span class="st"> </span>function(x, y) {
  cond &lt;-<span class="st"> </span>(x &lt;<span class="st"> </span>y)
  cond *<span class="st"> </span>x^<span class="dv">2</span> -<span class="st"> </span>(<span class="dv">1</span> -<span class="st"> </span>cond) *<span class="st"> </span>y^<span class="dv">2</span>
}
<span class="kw">foo2</span>(<span class="dv">1</span>:<span class="dv">5</span>, <span class="dv">5</span>:<span class="dv">1</span>)</code></pre></div>
<pre><code>## [1]  1  4 -9 -4 -1</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">x &lt;-<span class="st"> </span><span class="kw">rnorm</span>(<span class="fl">1e4</span>)
y &lt;-<span class="st"> </span><span class="kw">rnorm</span>(<span class="fl">1e4</span>)
<span class="kw">print</span>(<span class="kw">microbenchmark</span>(
  <span class="kw">foo</span>(x, y),
  <span class="kw">foo2</span>(x, y),
  <span class="kw">fooRcpp</span>(x, y),
  <span class="kw">fooRcppSugar</span>(x, y)
))</code></pre></div>
<pre><code>## Unit: microseconds
##                expr     min       lq      mean  median       uq      max neval
##           foo(x, y) 510.535 542.6510 872.23474 563.510 716.9680 2439.447   100
##          foo2(x, y)  71.183  75.1560 147.17468  83.765  93.8635 1977.250   100
##       fooRcpp(x, y)  40.393  44.6970  63.59186  47.676  51.1535 1468.038   100
##  fooRcppSugar(x, y) 138.394 141.3745 179.16429 142.533 161.4045 1575.972   100</code></pre>
<p>Even if it is a vectorized base R function, <code>ifelse</code> is known to be slow.</p>
</div>
</div>
<div id="conclusion" class="section level2">
<h2>Conclusion</h2>
<p>Beware when you use the <code>ifelse</code> function. Moreover, if you make a substantial number of calls to it, be aware that it isn’t very fast, but it exists at least 3 faster alternatives to it.</p>
</div>
</section>
