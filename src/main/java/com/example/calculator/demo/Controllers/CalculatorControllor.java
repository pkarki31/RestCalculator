package com.example.calculator.demo.Controllers;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class CalculatorControllor {

    int num=0;

    @GetMapping("/sum/{value1}/{value2}")
    public String sum(@PathVariable int value1,@PathVariable int value2) {

        num = value1+value2;

        return "Sum is : "+num;
    }

    @GetMapping("/minus/{value1}/{value2}")
    public String subtract(@PathVariable int value1,@PathVariable int value2) {

        if(value1>value2) {
            num = value1 - value2;
        }

        else {

            num = value2 - value1;

        }

        return "Subtraction is : "+num;
    }

    @GetMapping("/multiply/{value1}/{value2}")
    public String multiply(@PathVariable int value1,@PathVariable int value2) {

        num = value1+value2;

        return "Multiplication is : "+num;
    }

    @GetMapping("/divide/{value1}/{value2}")
    public String divide(@PathVariable int value1,@PathVariable int value2) {

        if(value1>value2){

            num = value1/value2;
        }

        else {

            num = value2/value1;

        }


        return "Division is : "+num;
    }

    @GetMapping("/hello")
    public String hello() {
        return "Hello World";
    }

}
