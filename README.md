


```bash
curl -fsSL https://raw.githubusercontent.com/scottmonster/qyksys/refs/heads/master/bootstrap.sh | bash
```



```bash
python3 -c "import sys,urllib.request;sys.stdout.buffer.write(urllib.request.urlopen(sys.argv[1]).read())" \
  https://raw.githubusercontent.com/scottmonster/qyksys/refs/heads/master/bootstrap | bash
```




python3 -c "import sys,urllib.request;sys.stdout.buffer.write(urllib.request.urlopen(sys.argv[1]).read())" \
  https://raw.githubusercontent.com/scottmonster/qyksys/refs/heads/master/bootstrap > bootstrap && chmod +x bootstrap && ./bootstrap
