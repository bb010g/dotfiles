#!/usr/bin/env bash
# Copyright 2019-2021 bb010g \
exec jq -n -r --slurpfile orig <(git show "HEAD:${1-nix/sources.json}") --slurpfile new "${1-nix/sources.json}" -f "$0"
# SPDX-License-Identifier: ISC OR Apache-2.0

def debug(f): (f | debug | empty), .;

# The derivative of a type is its one-hole context.
#
# data Option a = None | Some a;
# Option(a) = 1 + a;
# Option'(a) = 0 + 1 = 1;
# data OptionContext a = OptionContext;
# data OptionZipper a = OptionZipper a (OptionContext a);
#
# data List a = Nil | Cons a (List a);
# List(t) = 1 + t * List(t);
# List(t) - 1 = t * List(t);
# (List(t) - 1) / List(t) = t;
# 1 - 1 / List(t) = t;
# 1 = t + 1 / List(t);
# 1 - t = 1 / List(t);
# List(t) = 1 / (1 - t);
# List'(t) = 1 / (1 - t) ^ 2;
# List'(t) = (1 / (1 - t)) ^ 2;
# List'(t) = List(t) ^ 2;
# List'(t) = List(t) * List(t);
# data ListContext a = ListContext (List a) (List a);
# data ListZipper a = ListZipper a (ListContext a);
#
# Fix(f) = f(Fix(f));
#
# d(g ∘ f)_(a) = d(g)_(f(a)) * d(f)_(a);
# d((g ∘ f)(a))/d(a) = d(g(f(a)))/d(f(a)) * d(f(a))/d(a);
# d(f(a, b))/d(a) = ∂(f(a, b))/∂(a) + ∂(f(a, b))/∂(b) * d(b)/d(a);
# d(f(a)(b))/d(a) = ∂(f(a)(b))/∂(a) + ∂(f(a)(b))/∂(b) * d(b)/d(a);
#
# data ListF a b = Nil | Cons a b;
# ListF(a)(b) = 1 + a * b;
# d(ListF(a)(b))/d(a)
#   = ∂(1 + a * b)/∂(a) + ∂(1 + a * b)/∂(b) * d(b)/d(a)
#   = b + a * d(b)/d(a);
#
# Const(a)(b) = a;
# d(Const(a))_(a) = d(Const(a)(b))/d(a)
#   = ∂(Const(a)(b))/∂(a) + ∂(Const(a)(b))/∂(b) * d(b)/d(a)
#   = ∂(a)/∂(a) + ∂(a)/∂(b) * d(b)/d(a)
#   = 1 + 0 * d(b)/d(a)
#   = 1;
# d(Const(a)(b))/d(b) =
#   = ∂(Const(a)(b))/∂(b) + ∂(Const(a)(b))/∂(a) * d(a)/d(b)
#   = ∂(a)/∂(b) + ∂(a)/∂(a) * d(a)/d(b)
#   = 0 + 1 * d(a)/d(b)
#   = d(a)/d(b);
# a(b) = a(Const(b)(c)) = (a ∘ Const(b))(c);
#
# Fix(f) = f(Fix(f)) = (f ∘ Fix)(f) = (f ∘ Fix ∘ Const(f))(∀(a)(a));
#   = f(f(Fix(f))) = (f ∘ f ∘ Fix)(f);
# f ∘ Fix = f ∘ f ∘ Fix;
# d(Fix(f(a)))/d(a) = d(f(a)(Fix(f(a))))/d(a)
#   = d(f(a)(Fix(f(a))))/d(Fix(f(a))) * d(Fix(f(a)))/d(a);
# d(f(a)(Fix(f(a))))/d(Fix(f(a))) = 1;
# d(Fix(f))_(a) = d((f ∘ Fix)(f))_(a)
#   = d(Fix(f(a)))/d(f(a)) * d(f(a))/d(a);
# d(f(Fix(f)))_(a) = d(f ∘ Fix ∘ Const(f))_(a)
#   = d(f)_((Fix ∘ Const(f))(a)) * d(Fix ∘ Const(f))_(a)
#   = d(f)_((Fix ∘ Const(f))(a)) * d(Fix)_(Const(f)(a)) * d(Const(f))_(a)
#   = d(f)_(Fix(f)) * d(Fix)_(f)
#
# List(a) = ListF(a, List(a)) = 1 + a * List(a);
# d(List(a))/d(a) = d(ListF(a, List(a))/d(a)
#   = List(a) + a * d(List(a))/d(a);
#   = ListF
# List'(a) = List(a) + a * List'(a);
# List'(a) = 1 + a * List(a) + a * List'(a);
# List'(a) =
# List'(a) = List(a) + a * List(a) + a ^ 2 * List'(a)
#   = 1 + a * List(a) + a * List(a) + a ^ 2 * List'(a)
#   = 1 + 2 * a * List(a) + a ^ 2 * List'(a);
# List(a) ^ 2 = List(a) * List(a) = (1 + a * List(a)) * (1 + a * List(a))
#   = 1 + 2 * a * List(a) + (a * List(a)) ^ 2
#   = 1 + 2 * a * List(a) + a ^ 2 * List(a) ^ 2;
# enum ListContext<T> { Left(List<T>), Right(T, Box<ListContext<T>) }
# List(a) = a * List'(a) - List'(a) = (a - 1) * List'(a);
# List'(a) = List(a) / (a - 1);
# List'(a) = 1 + a * List(a) + a * List'(a);
#
# d(Fix(f))/
#
# Fix'(f) = f'(Fix(f)) * Fix'(f);
# f'(Fix(f)) = 1;
#
# enum BTree<T> { Leaf(T), Node(Box<BTree<T>>, Box<BTree<T>>) }
# BTree(t) = t + BTree(t) * BTree(t);
# BTree(t) = t + BTree(t) ^ 2;
# BTree(t) - BTree(t) ^ 2 = t;
# (1 - BTree(t)) * BTree(t) = t;
