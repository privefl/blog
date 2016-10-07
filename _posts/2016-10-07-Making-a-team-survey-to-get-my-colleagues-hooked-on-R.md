---
title: "Making a team survey to get my colleagues hooked on R"
author: "Florian Privé"
date: "2016-10-07"
layout: post
---



<section class="main-content">
<p>In this post, I will talk about the presentation of R that I did today, in the first week of my PhD. Usually, it is a team-only presentation. Yet, other people came because they were interested in learning more about R.</p>
<div id="how-i-get-this-idea" class="section level2">
<h2>How I get this idea?</h2>
<p>I get the idea of doing an R presentation while reading <a href="https://www.r-bloggers.com/getting-your-colleagues-hooked-on-r/">Getting Your Colleagues Hooked on R</a> on <a href="https://www.r-bloggers.com/">R-bloggers</a>. I began by following the 7 tips of this post to make my presentation, which was a good starting point.</p>
<p>After a while, I feared that a general presentation would not get my team interested in R. So, I decided to set up a <a href="https://goo.gl/forms/LREeX5NORBJlCrcC3">google form</a> and ask them what they wanted to learn about R. It was the way to get sure that they would care.</p>
</div>
<div id="get-results-automatically" class="section level2">
<h2>Get results automatically</h2>
<p>Because I was writing my R Markdown presentation while they were answering the google form, I decided that I should get (and show) the results automatically (only by re-knitting my presentation).</p>
<div id="to-get-the-results" class="section level3">
<h3>To get the results</h3>
<p>I used the <code>gsheet</code> package (one could also use the <code>googlesheets</code> package):</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">library</span>(pacman)
<span class="kw">p_load</span>(magrittr, longurl, gsheet)

responses &lt;-<span class="st"> &quot;goo.gl/4zYmrw&quot;</span> %&gt;%<span class="st"> </span>expand_urls %&gt;%<span class="st"> </span>{<span class="kw">gsheet2tbl</span>(.$expanded_url)[, <span class="dv">2</span>]}</code></pre></div>
</div>
<div id="to-get-the-different-possible-choices-of-the-form" class="section level3">
<h3>To get the different possible choices of the form</h3>
<p>I got them directly from reading the website of the google form:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">p_load</span>(gsubfn, stringr)

questions &lt;-<span class="st"> </span>
<span class="st">  &quot;https://goo.gl/forms/LREeX5NORBJlCrcC3&quot;</span> %&gt;%
<span class="st">  </span><span class="kw">readLines</span>(<span class="dt">encoding =</span> <span class="st">&quot;UTF-8&quot;</span>) %&gt;%
<span class="st">  </span><span class="kw">strapply</span>(<span class="dt">pattern =</span> <span class="st">&quot;</span><span class="ch">\\</span><span class="st">[</span><span class="ch">\&quot;</span><span class="st">([^</span><span class="ch">\&quot;</span><span class="st">]*)</span><span class="ch">\&quot;</span><span class="st">,,,,0</span><span class="ch">\\</span><span class="st">]&quot;</span>) %&gt;%
<span class="st">  </span>unlist</code></pre></div>
<p>I couldn’t get them directly from the googlesheet because google doesn’t make the difference between a comma in the name of the choices and commas used to seperate multiple answers. If you know how to specify the separation when generating results from a google form, I’d like to know.</p>
</div>
<div id="to-print-the-results-directly-in-my-presentation" class="section level3">
<h3>To print the results directly in my presentation</h3>
<p>I used the chunk option <code>results='asis'</code>:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">counts &lt;-<span class="st"> </span><span class="kw">str_count</span>(responses, <span class="kw">coll</span>(questions))
counts.lvl &lt;-<span class="st"> </span>counts %&gt;%<span class="st"> </span>unique %&gt;%<span class="st"> </span><span class="kw">sort</span>(<span class="dt">decreasing =</span> <span class="ot">TRUE</span>) %&gt;%<span class="st"> </span><span class="kw">setdiff</span>(<span class="dv">0</span>)

printf &lt;-<span class="st"> </span>function(...) <span class="kw">cat</span>(<span class="kw">sprintf</span>(...))

for (n in counts.lvl) {
  if (n ==<span class="st"> </span><span class="dv">2</span>) <span class="kw">printf</span>(<span class="st">&quot;</span><span class="ch">\n</span><span class="st">***</span><span class="ch">\n</span><span class="st">&quot;</span>)
  <span class="kw">printf</span>(<span class="st">&quot;- for **%d** of you:</span><span class="ch">\n</span><span class="st">&quot;</span>, n)
  q.tmp &lt;-<span class="st"> </span>questions[counts ==<span class="st"> </span>n]
  for (q in q.tmp) {
    <span class="kw">printf</span>(<span class="st">&quot;    - %s</span><span class="ch">\n</span><span class="st">&quot;</span>, q)
  }
}</code></pre></div>
<p>in order to generate markdown from R code.</p>
</div>
<div id="getting-the-number-of-r-packages-on-cran" class="section level3">
<h3>Getting the number of R packages on CRAN</h3>
<p>I also wanted to show them how many package we have on CRAN, so I used:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">n &lt;-<span class="st"> </span><span class="kw">readLines</span>(<span class="st">&#39;https://cran.r-project.org/web/packages/&#39;</span>) %&gt;%
<span class="st">  </span>gsubfn::<span class="kw">strapply</span>(
    <span class="kw">paste</span>(<span class="st">&quot;Currently, the CRAN package repository&quot;</span>,
          <span class="st">&quot;features ([0-9]+) available packages.&quot;</span>)) %&gt;%
<span class="st">  </span>unlist</code></pre></div>
<p>and printed <code>n</code> as inline R code.</p>
</div>
</div>
<div id="conclusion" class="section level2">
<h2>Conclusion</h2>
<p>You can see the presentation <a href="https://privefl.github.io/R-presentation/pResentation.html">there</a> and the corresponding Rmd file <a href="https://privefl.github.io/R-presentation/pResentation.Rmd">there</a>.</p>
<p>After finishing my presentation, I realized that most of what I presented, I learned it on R-bloggers. So, thanks everyone for the wonderful posts we get to read everyday!</p>
<p>If some of you think about other things that are important to know about R, I’d like to hear about them, just as personal curiosity.</p>
</div>
</section>
