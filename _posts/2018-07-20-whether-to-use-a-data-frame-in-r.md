---
title: "Whether to use a data frame in R?"

author: "Florian Privé"
date: "July 20, 2018"
layout: post
---


<section class="main-content">
<p>In this post, I try to show you in which situations using a data frame is appropriate, and in which it’s not.</p>
<p>Learn more with the <a href="https://adv-r.hadley.nz/">Advanced R book</a>.</p>
<div id="what-is-a-data-frame" class="section level2">
<h2>What is a data frame?</h2>
<p>A data frame is just a list of vectors of the same length, each vector being a column.</p>
<p>This may convince you:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">str</span>(iris)</code></pre></div>
<pre><code>## &#39;data.frame&#39;:    150 obs. of  5 variables:
##  $ Sepal.Length: num  5.1 4.9 4.7 4.6 5 5.4 4.6 5 4.4 4.9 ...
##  $ Sepal.Width : num  3.5 3 3.2 3.1 3.6 3.9 3.4 3.4 2.9 3.1 ...
##  $ Petal.Length: num  1.4 1.4 1.3 1.5 1.4 1.7 1.4 1.5 1.4 1.5 ...
##  $ Petal.Width : num  0.2 0.2 0.2 0.2 0.2 0.4 0.3 0.2 0.2 0.1 ...
##  $ Species     : Factor w/ 3 levels &quot;setosa&quot;,&quot;versicolor&quot;,..: 1 1 1 1 1 1 1 1 1 1 ...</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">is.list</span>(iris)</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">length</span>(iris)</code></pre></div>
<pre><code>## [1] 5</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">sapply</span>(iris, typeof)</code></pre></div>
<pre><code>## Sepal.Length  Sepal.Width Petal.Length  Petal.Width      Species 
##     &quot;double&quot;     &quot;double&quot;     &quot;double&quot;     &quot;double&quot;    &quot;integer&quot;</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">sapply</span>(iris, length)</code></pre></div>
<pre><code>## Sepal.Length  Sepal.Width Petal.Length  Petal.Width      Species 
##          150          150          150          150          150</code></pre>
</div>
<div id="what-is-a-list" class="section level2">
<h2>What is a list?</h2>
<p>A list is just a vector of references to objects in memory.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">x &lt;-<span class="st"> </span><span class="dv">1</span><span class="op">:</span><span class="fl">1e6</span>
pryr<span class="op">::</span><span class="kw">object_size</span>(x)</code></pre></div>
<pre><code>## 4 MB</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">y &lt;-<span class="st"> </span><span class="kw">list</span>(x, x, x)
pryr<span class="op">::</span><span class="kw">object_size</span>(y)</code></pre></div>
<pre><code>## 4 MB</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">address &lt;-<span class="st"> </span>data.table<span class="op">::</span>address
<span class="kw">address</span>(x)</code></pre></div>
<pre><code>## [1] &quot;000000001E49C530&quot;</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">sapply</span>(y, address)</code></pre></div>
<pre><code>## [1] &quot;000000001E49C530&quot; &quot;000000001E49C530&quot; &quot;000000001E49C530&quot;</code></pre>
<p>So, basically, here <code>y</code> is a vector of 3 references, each pointing to the same object <code>x</code> in memory. This is very efficient because there is no need to copy <code>x</code> 3 times when creating <code>y</code>.</p>
</div>
<div id="using-package-dplyr" class="section level2">
<h2>Using package {dplyr}</h2>
<p>Using {dplyr} operations such as <code>mutate</code> or <code>select</code> is very efficient.</p>
<ul>
<li><p><code>select</code>:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">library</span>(dplyr)
mydf &lt;-<span class="st"> </span>iris
mydf2 &lt;-<span class="st"> </span><span class="kw">select</span>(mydf, <span class="op">-</span>Species)
<span class="kw">sapply</span>(mydf, address)</code></pre></div>
<pre><code>##       Sepal.Length        Sepal.Width       Petal.Length        Petal.Width            Species 
## &quot;000000001CE852F8&quot; &quot;000000001BC64EB8&quot; &quot;000000000B965428&quot; &quot;000000000B39A758&quot; &quot;000000000B356168&quot;</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">sapply</span>(mydf2, address)</code></pre></div>
<pre><code>##       Sepal.Length        Sepal.Width       Petal.Length        Petal.Width 
## &quot;000000001CE852F8&quot; &quot;000000001BC64EB8&quot; &quot;000000000B965428&quot; &quot;000000000B39A758&quot;</code></pre>
<p>So, when you use <code>select</code>, you get a new object. This object is a new data frame (a new list). Yet, remember that a list is nothing but a vector of references. So, this is extremely efficient because it creates only a new vector of 4 references pointing to objects already in memory.</p></li>
<li><p><code>mutate</code>:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">mydf3 &lt;-<span class="st"> </span><span class="kw">mutate</span>(iris, <span class="dt">Species =</span> <span class="kw">as.character</span>(Species))
<span class="kw">sapply</span>(mydf, address)</code></pre></div>
<pre><code>##       Sepal.Length        Sepal.Width       Petal.Length        Petal.Width            Species 
## &quot;000000001CE852F8&quot; &quot;000000001BC64EB8&quot; &quot;000000000B965428&quot; &quot;000000000B39A758&quot; &quot;000000000B356168&quot;</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">sapply</span>(mydf3, address)</code></pre></div>
<pre><code>##       Sepal.Length        Sepal.Width       Petal.Length        Petal.Width            Species 
## &quot;000000001CE852F8&quot; &quot;000000001BC64EB8&quot; &quot;000000000B965428&quot; &quot;000000000B39A758&quot; &quot;0000000020451AB0&quot;</code></pre>
<p>This is the same when using <code>mutate</code>. You get a new object, yet you modified the 5-th variable only. So, the first 4 variables don’t have to be copied, your new data frame (list) can just point to the same 4 vectors in memory. R only creates a new vector of character and points to it in the new object.</p></li>
</ul>
<p>So, adding/removing/modifying one variable of a data frame is efficient because R doesn’t have to copy the other variables.</p>
</div>
<div id="what-about-modifying-one-row-of-a-data-frame" class="section level2">
<h2>What about modifying one row of a data frame?</h2>
<p>If you modify the first row of a data frame, then you modify the first element of each variable. If there are multiple references to these vectors, R would decide to copy them all, getting you a full copy of the data frame.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">mydf4 &lt;-<span class="st"> </span>mydf3
<span class="kw">sapply</span>(mydf3, address)</code></pre></div>
<pre><code>##       Sepal.Length        Sepal.Width       Petal.Length        Petal.Width            Species 
## &quot;000000001CE852F8&quot; &quot;000000001BC64EB8&quot; &quot;000000000B965428&quot; &quot;000000000B39A758&quot; &quot;0000000020451AB0&quot;</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">sapply</span>(mydf4, address)</code></pre></div>
<pre><code>##       Sepal.Length        Sepal.Width       Petal.Length        Petal.Width            Species 
## &quot;000000001CE852F8&quot; &quot;000000001BC64EB8&quot; &quot;000000000B965428&quot; &quot;000000000B39A758&quot; &quot;0000000020451AB0&quot;</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">mydf4[<span class="dv">1</span>, ] &lt;-<span class="st"> </span>mydf3[<span class="dv">1</span>, ]
<span class="kw">sapply</span>(mydf4, address)</code></pre></div>
<pre><code>##       Sepal.Length        Sepal.Width       Petal.Length        Petal.Width            Species 
## &quot;0000000029BAB238&quot; &quot;0000000029BAB718&quot; &quot;000000002841AB70&quot; &quot;000000002841B050&quot; &quot;000000002841B530&quot;</code></pre>
</div>
<div id="conclusion" class="section level2">
<h2>Conclusion</h2>
<p>It is appropriate to use data frames when you want to operate on variables, but not when you want to operate on rows. If you still want or need to do so, I recommend you to watch <a href="https://www.rstudio.com/resources/webinars/thinking-inside-the-box-you-can-do-that-inside-a-data-frame/">this webinar</a>.</p>
</div>
</section>
