---
title: "Teaching an advanced R course"

author: "Florian Privé"
date: "March 29, 2018"
layout: post
---


<section class="main-content">
<p>In this post, I come back to my first experience teaching an advanced R course over the past month.</p>
<p><a href="https://privefl.github.io/advr38book/" target="_blank"> <img src="../images/learnR.png" width="50%" style="display: block; margin: auto;" /> </a></p>
<div id="content" class="section level2">
<h2>Content</h2>
<p>This course was programmed for 10 sessions (3 hours each) and I initially wanted to talk about the following subjects:</p>
<ol style="list-style-type: decimal">
<li><p>R programming and good practices (2 sessions)</p></li>
<li><p>Data analysis with the tidyverse (3 sessions)</p></li>
<li><p>R code performance (2 sessions)</p></li>
<li><p>R packages (2 sessions)</p></li>
<li><p>Bonus: Shiny (1 session)</p></li>
</ol>
<p>I basically sticked to this.</p>
<p>I should also mention the public: PhD students.</p>
</div>
<div id="materials" class="section level2">
<h2>Materials</h2>
<p>At first, I wanted to do an interactive course using package <a href="https://rstudio.github.io/learnr/">{learnr}</a> but it would have required way too much work (my thesis supervisor would not have been happy!). So, finally I decided to use package <a href="https://bookdown.org/yihui/bookdown/">{bookdown}</a>. Using {bookdown} was really easy, and knowing how to use it now will spare me some time when I will write my thesis manuscript.</p>
<p>Materials are available <a href="https://privefl.github.io/advr38book/index.html">there</a>.</p>
<p>I also decided to create an associated package for mainly two reasons:</p>
<ul>
<li><p>to make students install package dependencies that we needed in this course,</p></li>
<li><p>to make solutions available for <a href="https://privefl.github.io/advr38book/performance.html">the chapter on code performance</a>.</p></li>
</ul>
<p>This idea of having a bookdown for materials with an associated package is not new (e.g. see <a href="https://bookdown.org/csgillespie/efficientR/">the <em>Efficient R Programming</em> book</a> and <a href="https://github.com/csgillespie/efficient">its associated package</a>).</p>
<p>I also introduced my students to <a href="https://slack.com">Slack</a> so that we could communicate and share code.</p>
</div>
<div id="all-chapters" class="section level2">
<h2>All chapters</h2>
<ol style="list-style-type: decimal">
<li><p>I started the course with <a href="https://privefl.github.io/advr38book/good-practices.html">good practices</a> such as coding style, using RStudio and Git, and getting help.</p></li>
<li><p>I continued the course with some <a href="https://privefl.github.io/advr38book/r-programming.html">base R programming</a>. This is not the funniest part of the course, but knowing this seemed to me as inevitable to be proficient in R.</p></li>
<li><p>Then, <a href="https://privefl.github.io/advr38book/tidyverse.html">we learned about the tidyverse</a> using <a href="http://r4ds.had.co.nz/">the R for Data Science book</a>. While teaching this course, I have discovered that many people still don’t use {ggplot2} and {dplyr}. So, I had to introduce these two packages from scratch and it took me longer than I had anticipated. In 3 sessions (9h), I had the time to cover R Markdown, {ggplot2} and {dplyr} only.</p></li>
<li><p>After the tidyverse, I covered <a href="https://privefl.github.io/advr38book/performance.html">performance of R code</a>. I really like to solve performance problems on Stack Overflow and (I think) I’m really good at it. So, this may have been the chapter I could bring the most to the table. Moreover, one student came with one of the problem she had, and I used her problem as an exercise. At the end, she was able to make her code more than 1000 times faster. For the other exercises, I mainly used problems I had answered on Stack Overflow.</p></li>
<li><p>For the last chapter, we covered <a href="https://privefl.github.io/advr38book/packages.html">how to make an R package</a>. I showed them that it was really easy and fast, mainly thanks to packages {usethis} and {roxygen2}. We had time to cover the full documentation, testing, automatic checking of packages and even how to make a website of a package.</p></li>
<li><p>Finally, the last session was a “bonus” session we could use either to spend more time on any topic or just to learn something fun like {Shiny}. Indeed, we could have spent at least two more sessions on the tidyverse and one on practicing about performance of R code. Using a <a href="https://simplepoll.rocks/">Slack poll</a>, we agreed to <a href="https://privefl.github.io/advr38book/shiny.html">learn Shiny</a>. For this, I used <a href="https://www.datacamp.com/courses/building-web-applications-in-r-with-shiny">this nice and free DataCamp course</a>.</p></li>
</ol>
</div>
<div id="retrospective-thoughts" class="section level2">
<h2>Retrospective thoughts</h2>
<ol style="list-style-type: decimal">
<li><p>At least half of the materials I used is borrowed from others. At first, I felt bad about this because I felt lazy. But it has already taken me a lot of time to prepare these materials, just reinventing the wheel with some new materials that were already out there would have not been good for me or my students.</p></li>
<li><p>I think using {bookdown}, Git and Slack was a good idea.</p></li>
<li><p>I feel like I’ve covered lots of useful things. However, I would have wanted my course to be useful for more people (I had only ~10 students). Hopefully these materials will be useful for other people outside Grenoble, France.</p>
<p>So don’t hesitate to comment this post or ask some questions!</p></li>
</ol>
</div>
</section>
