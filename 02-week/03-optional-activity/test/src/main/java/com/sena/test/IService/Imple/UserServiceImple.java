//La implementación de la interfaz, Logica del negocio: validaciones y lo que decide que hacer
package com.sena.test.IService.Imple;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.sena.test.Dto.UserDto;
import com.sena.test.Entity.User;
import com.sena.test.IRepository.UserRepository;
import com.sena.test.IService.IUserService;

@Service
public class UserServiceImple implements IUserService {

    @Autowired
    private UserRepository repository;

    @Override
    public List<User> findAll() {

    //Va a la DB y trae todos los usuarios
    List<User> user = repository.findAll();

    //Recorre cada usuario uno por uno
    return user.stream()
        .map(this::entityToDto) //quita el password en entityToDto 
        .toList(); //convierte todo en una lista
    }

    @Override 
    public User findById(int id){
        return repository.findById(id).orElse(null);
    }

    @Override
    public String update(int id, UserDto userDto){
        User user = repository.findById(id).orElse(null);

        if(user == null){
            return "Usuario no encontrado";
    }

    user.setUser_name(userDto.getUser_name());
    user.setEmail(userDto.getEmail());

    //Sirve para cuando no queremos actualizar la contraseña
    if(userDto.getPassword() != null && !userDto.getPassword().isEmpty()){ //valida el espacio no este vacio
    user.setPassword(userDto.getPassword());
    }

    repository.save(user);
    return "Usuario actualizado correctamente";
    }

    @Override
    public List<User> filterByName(String user_name){
        return repository.filterByName(user_name);
    }

    public User dtoToEntity(UserDto UserDto){
        return new User(
            UserDto.getId(),
            UserDto.getUser_name(),
            UserDto.getEmail(),
            UserDto.getPassword()
        );
    }

    public User entityToDto(User user){
        return new User(
            user.getId(),
            user.getUser_name(),
            user.getEmail(),
            ""
        );
    }

    @Override
    public String save(UserDto userDto){
        User user = dtoToEntity(userDto);
        repository.save(user);
        return "User guardado correctamente";
    }

    @Override
    public String delete(int id){
        repository.deleteById(id);
        return null;
    }
}