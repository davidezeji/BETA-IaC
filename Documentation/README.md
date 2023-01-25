# About d2

D2 is a diagram scripting language that turns text to diagrams. It stands for Declarative Diagramming. Declarative, as in, you describe what you want diagrammed, it generates the image.

[D2's Homepage](https://d2lang.com/tour/intro/)

[aws_accounts.json diagram](aws_accounts_json.png)

[gitlab-ci diagram](GitlabPipeline.png)

## Output d2 file to png

Commands to create updated png images using D2:

``` bash
# Create updated aws_accounts_json.png
d2 -w aws_accounts_json.d2 aws_accounts_json.png

# Create updated GitlabPipeline.png
d2 -w GitlabPipeline.d2 GitlabPipeline.png
```
