# Домашнее задание к занятию "7.5. Основы golang"

С `golang` в рамках курса, мы будем работать не много, поэтому можно использовать любой IDE. 
Но рекомендуем ознакомиться с [GoLand](https://www.jetbrains.com/ru-ru/go/).  

## Задача 1. Установите golang.
1. Воспользуйтесь инструкций с официального сайта: [https://golang.org/](https://golang.org/).
2. Так же для тестирования кода можно использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

Скачиваем дистрибутив с официального сайта: https://go.dev/dl/go1.18.2.linux-amd64.tar.gz,
разархивируем его:
```shell
dmitriy@dellix:~$ sudo tar -C /usr/local -xzf go1.18.2.linux-amd64.tar.gz
```
добавляем go/bin в переменную path - для этого добавим в конец файла $HOME/.profile следующую конструкцию:
```shell
if [ -d "/usr/local/go/bin" ] ; then
   export PATH=$PATH:/usr/local/go/bin
fi 
```
обновляем профиль:
```shell
dmitriy@dellix:~$ source ~/.profile
```
проверяем версию установленной программы:
```shell
dmitriy@dellix:~$ go version
go version go1.18.2 linux/amd64
```

## Задача 2. Знакомство с gotour.
У Golang есть обучающая интерактивная консоль [https://tour.golang.org/](https://tour.golang.org/). 
Рекомендуется изучить максимальное количество примеров. В консоли уже написан необходимый код, 
осталось только с ним ознакомиться и поэкспериментировать как написано в инструкции в левой части экрана.  

## Задача 3. Написание кода. 
Цель этого задания закрепить знания о базовом синтаксисе языка. Можно использовать редактор кода 
на своем компьютере, либо использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные 
у пользователя, а можно статически задать в коде.
    Для взаимодействия с пользователем можно использовать функцию `Scanf`:
    ```
    package main
    
    import "fmt"
    
    func main() {
        fmt.Print("Enter a number: ")
        var input float64
        fmt.Scanf("%f", &input)
    
        output := input * 2
    
        fmt.Println(output)    
    }
    ```
   
Ответ:

```
dmitriy@dellix:~/go_test$ cat m2f_convert.go
package main

import "fmt"

func mconvert(meter float64) (foot float64) {
    foot = meter / 0.3048
    return
}

func main() {
    fmt.Print("Введите количество метров: ")
    var input float64
    fmt.Scanf("%f", &input)
    output := mconvert(input)
    fmt.Println("В", input, "м, содержится", output, "ф")
}
``` 

2. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:
    ```
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
    ```
Ответ:
```
dmitriy@dellix:~/go_test$ cat minimal_element.go 
package main

import "fmt"


func min(x []int) (emin int) {
     emin = x[0]
   for _, element := range x {
      if element < emin {
         emin = element
      }
   }
   return
}

func main() {
   x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}	
    vmin := min(x)
    fmt.Println(vmin)
}
```

3. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть `(3, 6, 9, …)`.
```
package main

import "fmt"

func main() {
    for i :=1; i <= 100; i++ {
        if i % 3 == 0 {
            fmt.Println(i)
        }
    }
}
```
вариант 2
```
package main

import "fmt"

func smod() (slist []int) {
   for i :=3; i <= 100; {
        slist = append(slist, i)
        i = i + 3
   }
   return
}

func main() {
    svar := smod()
    fmt.Println(svar)
}
```

В виде решения ссылку на код или сам код. 

## Задача 4. Протестировать код (не обязательно).

Создайте тесты для функций из предыдущего задания. 

```
dmitriy@dellix:~/go_test$ cat test m2f_convert_test.go 
cat: test: Нет такого файла или каталога
package main

import "testing"

func TestMain(t *testing.T) {
	var v float64
	v = mconvert(25)
	if v != 82.02099737532808 {
		t.Error("должно быть 82.02099737532808, а выдало ", v)
	}
}
```

```
dmitriy@dellix:~/go_test$ go test m2f_convert.go m2f_convert_test.go 
ok  	command-line-arguments	0.001s
```
в программе исправим foot = meter / 0.3048 например на foot = meter / 0.3048 + 1
получим ошибку
```
dmitriy@dellix:~/go_test$ go test m2f_convert.go m2f_convert_test.go 
--- FAIL: TestMain (0.00s)
    m2f_convert_test.go:9: должно быть 82.02099737532808, а выдало  83.02099737532808
FAIL
FAIL	command-line-arguments	0.001s
FAIL
```

```
dmitriy@dellix:~/go_test$ cat minimal_element_test.go 
package main

import "testing"

func TestMain(t *testing.T) {
	var m int
	m = min([]int{10,1,30})
	if m != 1 {
		t.Error("Ожидается 1, выдает ", m)
	}
}
dmitriy@dellix:~/go_test$ go test minimal_element.go minimal_element_test.go 
ok  	command-line-arguments	0.001s
```

```
package main

import "fmt"
import "testing"

func TestMain(t *testing.T) {
	var s []int
	s = smod()
	if s[4] != 15 || s[23] != 72 {
		s4 := s[4]
		s23 := s[23]
		e := fmt.Sprint("Ожидаются значения 15 и 72, выведены", s4, "и", s23)
		t.Error(e)
	}
}
```
в этом тесте проверяется только значение двух элементов, остальные элементы и их количество могут быть любыми, тест их не отслеживает.

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---

