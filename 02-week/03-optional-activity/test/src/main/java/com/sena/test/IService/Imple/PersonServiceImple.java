package com.sena.test.IService.Imple;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.sena.test.Dto.PersonDto;
import com.sena.test.Entity.Person;
import com.sena.test.IRepository.PersonRepository;
import com.sena.test.IService.IPersonService;

@Service
public class PersonServiceImple implements IPersonService {

    @Autowired
    private PersonRepository repo;

    @Override
    public List<Person> findAll(){
        return repo.findAll();
    }

    @Override
    public Person findById(int id){
        return repo.findById(id).orElse(null);
    }

    @Override
    public List<Person> filterByEdad(int edad){
        return repo.filterByEdad(edad);
    }

    @Override
    public String update(int id, PersonDto personDto){
        Person person = repo.findById(id).orElse(null);

        if (person == null){
            return "usuario no encontrado";
        }

        person.setEdad(personDto.getEdad());
        person.setName(personDto.getName());

        repo.save(person);
        return "Usuario actualizado correctamente";
        }

    public Person dtoToEntity(PersonDto personDto){
        return new Person(
            personDto.getId(),
            personDto.getName(),
            personDto.getEdad()
        );
    }

    public Person entityToDto(Person person){
        return new Person(
            person.getId(),
            person.getName(),
            person.getEdad()
        );
    }

    @Override
    public String save(PersonDto p){
        Person person = dtoToEntity(p);
        repo.save(person);
        return "La persona se guardo exitosamente";
    }

    @Override
    public String delete(int id){
        repo.deleteById(id);
        return null;
    }
}