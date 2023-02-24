sudo apt update
sudo apt install qutebrowser
read -r -n 1 -p "do you want to copy configs too? [y/n]" ans
case "$ans" in
 y|Y ) echo "You chose: YES"
if [[ -d ./qutebrowser ]]; then
  echo "Copying config of qutebrowser"
  rsync -aP ./qutebrowser/ ~/.config/qutebrowser/
else
  echo "WARNING: no qutebrowser directory found. skip copy"
fi
;;
 n|N )
  echo "You chose NO"
  ;;
 *)
  echo "invalid answer: $ans"
  exit 1
  ;;
esac
echo "----- done -----"
