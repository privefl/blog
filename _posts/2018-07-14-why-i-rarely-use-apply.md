---
title: "Why I rarely use apply"

author: "Florian Privé"
date: "July 14, 2018"
layout: post
---


<section class="main-content">
<p>In this short post, I talk about why I’m moving away from using function <code>apply</code>.</p>
<div id="with-matrices" class="section level2">
<h2>With matrices</h2>
<p>It’s okay to use <code>apply</code> with a dense matrix, although you can often use an equivalent that is faster.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">N &lt;-<span class="st"> </span>M &lt;-<span class="st"> </span><span class="dv">8000</span>
X &lt;-<span class="st"> </span><span class="kw">matrix</span>(<span class="kw">rnorm</span>(N <span class="op">*</span><span class="st"> </span>M), N)
<span class="kw">system.time</span>(res1 &lt;-<span class="st"> </span><span class="kw">apply</span>(X, <span class="dv">2</span>, mean))</code></pre></div>
<pre><code>##    user  system elapsed 
##    0.73    0.05    0.78</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">system.time</span>(res2 &lt;-<span class="st"> </span><span class="kw">colMeans</span>(X))</code></pre></div>
<pre><code>##    user  system elapsed 
##    0.05    0.00    0.05</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">stopifnot</span>(<span class="kw">isTRUE</span>(<span class="kw">all.equal</span>(res2, res1)))</code></pre></div>
<p>“Yeah, there are <code>colSums</code> and <code>colMeans</code>, but what about computing standard deviations?”</p>
<p>There are lots of <code>apply</code>-like functions in <a href="https://cran.r-project.org/package=matrixStats">package {matrixStats}</a>.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">system.time</span>(res3 &lt;-<span class="st"> </span><span class="kw">apply</span>(X, <span class="dv">2</span>, sd))</code></pre></div>
<pre><code>##    user  system elapsed 
##    0.96    0.01    0.97</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">system.time</span>(res4 &lt;-<span class="st"> </span>matrixStats<span class="op">::</span><span class="kw">colSds</span>(X))</code></pre></div>
<pre><code>##    user  system elapsed 
##     0.2     0.0     0.2</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">stopifnot</span>(<span class="kw">isTRUE</span>(<span class="kw">all.equal</span>(res4, res3)))</code></pre></div>
</div>
<div id="with-data-frames" class="section level2">
<h2>With data frames</h2>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">head</span>(iris)</code></pre></div>
<pre><code>##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
## 1          5.1         3.5          1.4         0.2  setosa
## 2          4.9         3.0          1.4         0.2  setosa
## 3          4.7         3.2          1.3         0.2  setosa
## 4          4.6         3.1          1.5         0.2  setosa
## 5          5.0         3.6          1.4         0.2  setosa
## 6          5.4         3.9          1.7         0.4  setosa</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">apply</span>(<span class="kw">head</span>(iris), <span class="dv">2</span>, identity)</code></pre></div>
<pre><code>##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species 
## 1 &quot;5.1&quot;        &quot;3.5&quot;       &quot;1.4&quot;        &quot;0.2&quot;       &quot;setosa&quot;
## 2 &quot;4.9&quot;        &quot;3.0&quot;       &quot;1.4&quot;        &quot;0.2&quot;       &quot;setosa&quot;
## 3 &quot;4.7&quot;        &quot;3.2&quot;       &quot;1.3&quot;        &quot;0.2&quot;       &quot;setosa&quot;
## 4 &quot;4.6&quot;        &quot;3.1&quot;       &quot;1.5&quot;        &quot;0.2&quot;       &quot;setosa&quot;
## 5 &quot;5.0&quot;        &quot;3.6&quot;       &quot;1.4&quot;        &quot;0.2&quot;       &quot;setosa&quot;
## 6 &quot;5.4&quot;        &quot;3.9&quot;       &quot;1.7&quot;        &quot;0.4&quot;       &quot;setosa&quot;</code></pre>
<p><img src="../images/as-matrix.jpg" width="500" /></p>
<p>A DATA FRAME IS NOT A MATRIX (it’s a list).</p>
<p>The first thing that <code>apply</code> does is converting the object to a matrix, which consumes memory and in the previous example transforms all data as strings (because a matrix can have only one type).</p>
<p>What can you use as a replacement of <code>apply</code> with a data frame?</p>
<ul>
<li><p>If you want to operate on all columns, since a data frame is just a list, you can use <code>sapply</code> instead (or <code>map*</code> if you are a purrrist).</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">sapply</span>(iris, typeof)</code></pre></div>
<pre><code>## Sepal.Length  Sepal.Width Petal.Length  Petal.Width      Species 
##     &quot;double&quot;     &quot;double&quot;     &quot;double&quot;     &quot;double&quot;    &quot;integer&quot;</code></pre></li>
<li><p>If you want to operate on all rows, I recommend you to watch <a href="https://www.rstudio.com/resources/webinars/thinking-inside-the-box-you-can-do-that-inside-a-data-frame/">this webinar</a>.</p></li>
</ul>
</div>
<div id="with-sparse-matrices" class="section level2">
<h2>With sparse matrices</h2>
<p>The memory problem is even more important when using <code>apply</code> with sparse matrices, which makes using <code>apply</code> very slow for such data.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">library</span>(Matrix)

X.sp &lt;-<span class="st"> </span><span class="kw">rsparsematrix</span>(N, M, <span class="dt">density =</span> <span class="fl">0.01</span>)

## X.sp is converted to a dense matrix when using `apply`
<span class="kw">system.time</span>(res5 &lt;-<span class="st"> </span><span class="kw">apply</span>(X.sp, <span class="dv">2</span>, mean))  </code></pre></div>
<pre><code>##    user  system elapsed 
##    0.78    0.46    1.25</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">system.time</span>(res6 &lt;-<span class="st"> </span>Matrix<span class="op">::</span><span class="kw">colMeans</span>(X.sp))</code></pre></div>
<pre><code>##    user  system elapsed 
##    0.01    0.00    0.02</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">stopifnot</span>(<span class="kw">isTRUE</span>(<span class="kw">all.equal</span>(res6, res5)))</code></pre></div>
<p>You could implement your own <code>apply</code>-like function for sparse matrices by seeing a sparse matrix as a data frame with 3 columns (<code>i</code> and <code>j</code> storing positions of non-null elements, and <code>x</code> storing values of these elements). Then, you could use a <code>group_by</code>-<code>summarize</code> approach.</p>
<p>For instance, for the previous example, you can do this in base R:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">apply2_sp &lt;-<span class="st"> </span><span class="cf">function</span>(X, FUN) {
  res &lt;-<span class="st"> </span><span class="kw">numeric</span>(<span class="kw">ncol</span>(X))
  X2 &lt;-<span class="st"> </span><span class="kw">as</span>(X, <span class="st">&quot;dgTMatrix&quot;</span>)
  tmp &lt;-<span class="st"> </span><span class="kw">tapply</span>(X2<span class="op">@</span>x, X2<span class="op">@</span>j, FUN)
  res[<span class="kw">as.integer</span>(<span class="kw">names</span>(tmp)) <span class="op">+</span><span class="st"> </span><span class="dv">1</span>] &lt;-<span class="st"> </span>tmp
  res
}

<span class="kw">system.time</span>(res7 &lt;-<span class="st"> </span><span class="kw">apply2_sp</span>(X.sp, sum) <span class="op">/</span><span class="st"> </span><span class="kw">nrow</span>(X.sp))</code></pre></div>
<pre><code>##    user  system elapsed 
##    0.03    0.00    0.03</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">stopifnot</span>(<span class="kw">isTRUE</span>(<span class="kw">all.equal</span>(res7, res5)))</code></pre></div>
</div>
<div id="conclusion" class="section level2">
<h2>Conclusion</h2>
<p>Using <code>apply</code> with a dense matrix is fine, but try to avoid it if you have a data frame or a sparse matrix.</p>
</div>
</section>
