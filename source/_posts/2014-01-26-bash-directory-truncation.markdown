---
layout: post
title: "prompt working directory"
date: 2014-01-26 12:03:54 +0200
comments: true
categories: [ bash, zsh, shell, prompt ]
---

## TL;DR

Shorten `~/very/deep/down/the/rabbit/hole` to `⋯/the/rabbit/hole` in
prompt.

<!-- more -->

If you're staring at a shell prompt a few hours every day, you might as well
try to modify the prompt to better suit your needs.  Some people like a
minimalistic prompt with nothing but the working dir and a dollar sight `~ $`.
Others get an enormous 256-color multi-line beast holding information about the
kernel version, battery status, daily horoscope and what not. There's yet
another group which sticks with whatever their system's default is.

This post will hopefully come in handy for the first and second group.

## The Goal

The working directory should be readable no matter how
`~/very/deep/down/the/rabbit/hole` you're in in the file system. To maintain
readability, the working dir displayed in the prompt should contain no more
than three sub directories `⋯/the/rabbit/hole` 

Bash version 4+ actually has an option to do this `PROMPT_DIRTRIM=3`, but I
find it's behaviour ludicrous: it behaves (very) differently when the working
dir is a sub dir of $HOME or not.

Working dir is a subdir of $HOME:

``` sh
~ $ PROMPT_DIRTRIM=3
~ $ cd one/
~/one $ cd two/
~/one/two $ cd three/
~/one/two/three $ cd four/
~/one/two/three/four $ cd five/
~/.../three/four/five $
```

This is useless to me:

- Notice that when in dir `four`, the path is not truncated at all.
- The tilde `~` is never truncated

Working dir is not a subdir of $HOME:

``` sh
~ $ PROMPT_DIRTRIM=3
/ $ cd one/
/one $ cd two/
/one/two $ cd three/
/one/two/three $ cd four/
.../two/three/four $ cd five/
.../three/four/five $
```

This is much better! ... or not:

- Most of the time I'm somewhere in $HOME
- I would really like to use a single char `⋯` instead of three dots `...`.
  Screen real-estate does not come that cheap. I work with many vim/tmux panes,
  so cutting some fat here and there does make a difference.

Also, I've been wanting to improve my shell scripting skills for some time.
This seemed like a nice challenge.

## Truncate function

In theory, truncating the $PWD to 3 dirs seemed like a very simple task. In
practice, it turned out a (tiny) bit more complicated. In javascript (a
language I'm mostly unfamiliar with), this could be achieved with pretty much
one line of code:

(Note that this is greatly simplified and doesn't handle any corner cases.)
``` javascript
PWD.split('/').slice(-3).join('/')
```

How hard could it be to port this to bash (and zsh)?

One thing I want to stress is that external processes must **not** be created
to achieve this task. This function must be as fast as possible and forking off
`sed`, `awd` and what not, is not a viable option.

## The result

After some research on bash/zsh arrays, some head-banging and quite a bit of
coffee, I managed to achieve the desired result:

``` sh
~ $ cd one/two/three/four/repository/
⋯/three/four/repository $ cd /usr/local/Cellar/git/
⋯/local/Cellar/git $
```

In a subdir of $HOME:

``` sh
~ $ cd one/
~/one $ cd two/
~/one/two $ cd three/
⋯/one/two/three $ cd four/
⋯/two/three/four $ cd five/
```

Not in $HOME:

``` sh
/ $ cd one/
/one $ cd two/
/one/two $ cd three/
⋯/one/two/three $ cd four/
⋯/two/three/four $ cd five/
```

As a bonus, the separator can be configured, for example it could be ` > `

``` sh
~ $ cd one/
~ > one $ cd two/
~ > one > two $ cd three/
⋯ > one > two > three $ cd four/
⋯ > two > three > four $ cd five/
```

Plus, with some minor modifications, I got the function working with powerline
symbols for my [promptline.vim][1] plugin:

{% img /images/promptline_cwd.png %}

## The function itself

Hopefully it would be useful to someone else. I certainly learned a lot writing
(and re-writing) it. Enjoy!

``` sh
function truncated_cwd {
  # dir_limit and truncation can be configured
  local dir_limit="3"
  local truncation="⋯"

  local first_char
  local part_count=0
  local formatted_cwd=""
  local dir_sep=" | "

  local cwd="${PWD/#$HOME/~}"

  # get first char of the path, i.e. tilde or slash
  [[ -n ${ZSH_VERSION-} ]] && first_char=$cwd[1,1] || first_char=${cwd::1}

  # remove leading tilde
  cwd="${cwd#\~}"

  while [[ "$cwd" == */* && "$cwd" != "/" ]]; do
    # pop off last part of cwd
    local part="${cwd##*/}"
    cwd="${cwd%/*}"

    formatted_cwd="$dir_sep$part$formatted_cwd"
    part_count=$((part_count+1))

    [[ $part_count -eq $dir_limit ]] && first_char="$truncation" && break
  done

  [[ "$formatted_cwd" != $first_char* ]] && formatted_cwd="$first_char$formatted_cwd"
  printf "%s" "$formatted_cwd"
}
```

There are a few ways to get the function in the prompt, this is probably the
simplest one: 

``` sh
PS1='$(truncated_cwd) \$ '
```

[1]: https://github.com/edkolev/promptline.vim
