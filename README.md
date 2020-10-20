# bb010g/dotfiles

## [git-crypt][git-crypt] & [Git LFS][git-lfs]

A [Git LFS extension][git-lfs/docs/extensions] makes git-crypt work on top of Git LFS. The following should be added to your `.git/config`:

```gitconfig
[diff "cat"]
	textconv = cat
[lfs "extension.git-crypt"]
	clean = git-crypt clean
	smudge = git-crypt smudge
	priority = 0
```

To filter files with git-crypt from now on, set their `filter` & `diff` attributes to `filter=lfs diff=git-crypt`, and leave their `merge` attribute unspecified. This is not what Git LFS specifies by default (`filter=lfs diff=lfs merge=lfs`), but we're dealing with text files here. (Plus, Git LFS doesn't even ship a [diff driver][git-lfs#440] or a merge driver. Whee.) Ideally, extensions would be controllable with [gitattributes(5)][gitattributes(5)], but this is not currently implemented. The issue [gitattributes(5) should control paths' desired Git LFS extensions][git-lfs#4287] has been opened about this.

The `cat` diff driver isn't essential, but it makes text diffs on LFS tracked text files work (`diff=cat`).

[git-crypt]: https://www.agwa.name/projects/git-crypt/
[git-lfs]: https://git-lfs.github.com/
[git-lfs#440]: https://github.com/git-lfs/git-lfs/issues/440
[git-lfs#4287]: https://github.com/git-lfs/git-lfs/issues/4287
[git-lfs/docs/extensions]: https://github.com/git-lfs/git-lfs/blob/v2.12.0/docs/extensions.md
[gitattributes(5)]: https://www.git-scm.com/docs/gitattributes/2.28.0
