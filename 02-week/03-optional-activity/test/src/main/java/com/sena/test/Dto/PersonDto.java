package com.sena.test.Dto;

public class PersonDto {

    private Integer id;
    private String name;
    private Integer edad;

    public PersonDto(){}

    public PersonDto(Integer id, String name, Integer edad) {
        this.id = id;
        this.name = name;
        this.edad = edad;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getEdad() {
        return edad;
    }

    public void setEdad(Integer edad) {
        this.edad = edad;
    }
}