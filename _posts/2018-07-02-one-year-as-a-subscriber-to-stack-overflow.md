---
title: "One year as a subscriber to Stack Overflow"

author: "Florian Privé"
date: "July 2, 2018"
layout: post
---


<section class="main-content">
<p>In this post, I follow up on a <a href="https://privefl.github.io/blog/one-month-as-a-procrastinator-on-stack-overflow/">previous post</a> describing how last year in July, I spent one month mostly procrastinating on Stack Overflow (SO). We’re already in July so it’s time to get back to one year of activity on Stack Overflow.</p>
<p>Am I still as much active as before? <strong>What is my strategy for answering questions on SO?</strong></p>
<div id="my-activity-on-stack-overflow" class="section level2">
<h2>My activity on Stack Overflow</h2>
<p>Again, we’ll use David Robinson’s package {stackr} to get data from Stack Overflow API in R.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="co"># devtools::install_github(&quot;dgrtwo/stackr&quot;)</span>
<span class="kw">suppressMessages</span>({
  <span class="kw">library</span>(stackr)
  <span class="kw">library</span>(tidyverse)
  <span class="kw">library</span>(lubridate)
})</code></pre></div>
<div id="evolution-of-my-so-reputation" class="section level3">
<h3>Evolution of my SO reputation</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">myID &lt;-<span class="st"> &quot;6103040&quot;</span>

myRep &lt;-<span class="st"> </span><span class="kw">stack_users</span>(myID, <span class="st">&quot;reputation-history&quot;</span>, <span class="dt">num_pages =</span> <span class="dv">40</span>,
                     <span class="dt">fromdate =</span> <span class="kw">today</span>() <span class="op">-</span><span class="st"> </span><span class="kw">years</span>(<span class="dv">1</span>))

myRep <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">arrange</span>(creation_date) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">ggplot</span>(<span class="kw">aes</span>(creation_date, <span class="kw">cumsum</span>(reputation_change))) <span class="op">+</span>
<span class="st">  </span><span class="kw">geom_point</span>() <span class="op">+</span>
<span class="st">  </span><span class="kw">labs</span>(<span class="dt">x =</span> <span class="st">&quot;Date&quot;</span>, <span class="dt">y =</span> <span class="st">&quot;Reputation (squared transformed)&quot;</span>,
       <span class="dt">title =</span> <span class="st">&quot;Evolution of my SO reputation over the last year&quot;</span>) <span class="op">+</span><span class="st"> </span>
<span class="st">  </span>bigstatsr<span class="op">::</span><span class="kw">theme_bigstatsr</span>()</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-SO-year_files/figure-html/unnamed-chunk-2-1.png" width="80%" style="display: block; margin: auto;" /></p>
<p>So, it seems that my activity is slowing gently (my reputation is almost proportional to the square root of time). Yet, it is still increasing steadily; so what is my strategy for answering questions on SO?</p>
</div>
<div id="tags-im-involved-in" class="section level3">
<h3>Tags I’m involved in</h3>
<p>You’ll have to wait for the answer to what is my strategy for answering questions on SO. For a hint, let’s analyze the tags I’m involved in.</p>
<p>If we don’t count my first month of activity:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">stack_users</span>(myID, <span class="st">&quot;tags&quot;</span>, <span class="dt">num_pages =</span> <span class="dv">40</span>,
            <span class="dt">fromdate =</span> <span class="kw">today</span>() <span class="op">-</span><span class="st"> </span><span class="kw">months</span>(<span class="dv">11</span>)) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">select</span>(name, count) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">as_tibble</span>()</code></pre></div>
<pre><code>## # A tibble: 155 x 2
##    name                count
##    &lt;chr&gt;               &lt;int&gt;
##  1 r                     187
##  2 performance            36
##  3 rcpp                   34
##  4 parallel-processing    33
##  5 foreach                19
##  6 r-bigmemory            14
##  7 vectorization          12
##  8 for-loop               11
##  9 matrix                 11
## 10 doparallel             10
## # ... with 145 more rows</code></pre>
<p>I’m obviously answering only R questions. The tags I’m mostly answering questions from are “performance”, “rcpp”, “parallel-processing”, “foreach”, “r-bigmemory” and “vectorization”.</p>
</div>
<div id="performance" class="section level3">
<h3>Performance</h3>
<p>As you can see, all these tags are about performance of code. I really enjoy performance problems (get the same result but much faster).</p>
<p>I can spend hours on a question about performance and am sometimes rewarded with a solution that is 2-3 order of magnitude faster (see e.g. <a href="https://privefl.github.io/blog/performance-when-algorithmics-meets-mathematics/">this other post</a>).</p>
<p>I hope I could share my knowledge about performance through a tutorial in Toulouse next year.</p>
</div>
</div>
<div id="conclusion-and-answer" class="section level2">
<h2>Conclusion and answer</h2>
<p>So, the question was “What is my strategy for answering questions on SO?”. And the answer is.. in the title: I am a subscriber.</p>
<p>I subscribe to tags on Stack Overflow. It has many benefits:</p>
<ul>
<li><p>you don’t have to <a href="https://meta.stackexchange.com/questions/9731/fastest-gun-in-the-west-problem">rush to answer</a> because questions you receive by mail are 30min-old (unanswered?) ones, so the probability that someone will answer at the same time as you is low.</p></li>
<li><p>you can focus and what you’re good at, what you’re interested in, or just what you want to learn. For example, I subscribed to the very new tag “r-future” (for the R package {future}) because I’m interested in this package, even if I don’t know how to use it yet. I had the chance to meet with its author, Henrik Bengtsson, at eRum2018 and he actually already knew me through parallel questions on SO :D.</p></li>
</ul>
<p>However, some tags (like “performance” or “foreach”) are relevant to many programming languages so that you would be flooded with irrelevant questions if subscribing directly to these tags. A simple solution to this problem is to subscribe to a feed of a combination of tags, like <a href="https://stackoverflow.com/feeds/tag?tagnames=r+and+foreach&amp;sort=newest" class="uri">https://stackoverflow.com/feeds/tag?tagnames=r+and+foreach&amp;sort=newest</a>. I use <a href="https://blogtrottr.com/">this website</a> to subscribe to feeds.</p>
<p>I will continue answering questions on SO, so see you there!</p>
<hr />
<p>PS: I’m not sure you would get only unanswered questions with this technique.</p>
</div>
</section>
