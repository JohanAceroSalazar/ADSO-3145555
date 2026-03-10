package com.sena.test.IService;

import java.util.List;

import com.sena.test.Dto.PersonDto;
import com.sena.test.Entity.Person;

public interface IPersonService {

    public List<Person>findAll();
    public Person findById(int id);
    String update(int id, PersonDto personDto);
    public List<Person> filterByEdad(int edad);
    public String save(PersonDto p);
    public String delete(int id);
}