# run update code function
run-update-code-basic-setup () {
  # helpful commands to use to update this
  # file (pulled from https://stackoverflow.com/questions/35773299/how-can-you-export-the-visual-studio-code-extension-list):
  # code --list-extensions | xargs -L 1 echo code --install-extension
  local :w
  basic_setup_code_extensions=(
    "christianvoigt.argdown-vscode"
    "eamodio.gitlens"
    "golang.go"
    "hashicorp.terraform"
    "hediet.vscode-drawio"
    "mikestead.dotenv"
    "ms-azuretools.vscode-docker"
    "ms-dotnettools.csharp"
    "ms-dotnettools.vscode-dotnet-runtime"
    "ms-kubernetes-tools.vscode-kubernetes-tools"
    "ms-vscode-remote.remote-containers"
    "ms-vscode.azurecli"
    "ms-vscode.powershell"
    "ms-vscode.vscode-js-profile-flame"
    "msazurermtools.azurerm-vscode-tools"
    "redhat.vscode-commons"
    "redhat.vscode-yaml"
    "vscodevim.vim"
    "yzane.markdown-pdf"
  )

  for e in ${basic_setup_code_extensions[@]}; do
    code --install-extension "$e"
  done
}
