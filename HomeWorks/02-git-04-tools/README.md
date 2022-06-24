1 \
git show aefea 

commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545
Update CHANGELOG.md

2 \
git show 85024d3

commit 85024d3100126de36331c6982bfaac02cdab9e76 (tag: v0.12.23)

3 \
git show --pretty=format:'%P' b8d720

2родителя, 56cd7859e05c36c06b56d013b55a252d0bb7e158 9ea88f22fc6269854151c571162c5bcf958bee2b

4 \
git log  v0.12.23..v0.12.24  --oneline

33ff1c03b (tag: v0.12.24) v0.12.24 \
b14b74c49 [Website] vmc provider links \
3f235065b Update CHANGELOG.md \
6ae64e247 registry: Fix panic when server is unreachable \
5c619ca1b website: Remove links to the getting started guide's old location \
06275647e Update CHANGELOG.md \
d5f9411f5 command: Fix bug when using terraform login on Windows \
4b6d06cc5 Update CHANGELOG.md \
dd01a3507 Update CHANGELOG.md \
225466bc3 Cleanup after v0.12.23 release

5 \
git log -S'func providerSource' --oneline \
вернет 2 хеша \
5af1e6234 main: Honor explicit provider_installation CLI config when present \
8c928e835 main: Consult local directories as potential mirrors of providers \
смотрим нижний
git show 8c928e835 внутри ищем /providerSource
видим строчку +func providerSource(services *disco.Disco) getproviders.Source {
проверяем git show 5af1e6234 внутри ищем /providerSource видим что функцию переписали
-func providerSource(services *disco.Disco) getproviders.Source {
+func providerSource(configs []*cliconfig.ProviderInstallation, services *disco.Disco) (getproviders.Source, tfdiags.Diagnostics) {
ответ
commit 8c928e83589d90a031f811fae52a81be7153e82f

6 \
git log -L :'func globalPluginDirs':plugins.go | grep commit

commit 78b12205587fe839f10d946ea3fdc06719decb05 \
commit 52dbf94834cb970b510f2fba853a5b49ad9b1a46 \
commit 41ab0aef7a0fe030e84018973a64135b11abcd70 \
commit 66ebff90cdfaa6938f26f908c7ebad8d547fea17 \
commit 8364383c359a6b738a436d1b7745ccdce178df47 \
7 \
git log -S 'func synchronizedWriters' --pretty=format:'%h %an'
вернет 2 хеша \
bdfea50cc James Bardin \
5ac311e2a Martin Atkins \

смотрим нижний \
git show 5ac311e2a \
ищем /synchronizedWriters \
+func synchronizedWriters(targets ...io.Writer) []io.Writer { \

проверяем git show bdfea50cc \
щем /synchronizedWriters \
-func synchronizedWriters(targets ...io.Writer) []io.Writer {

commit 5ac311e2a91e381e2f52234668b49ba670aa0fe5 \
Author: Martin Atkins <mart@degeneration.co.uk> \
Date:   Wed May 3 16:25:41 2017 -0700