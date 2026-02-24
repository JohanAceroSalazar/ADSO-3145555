//Interfaz donde definimos los metodos que vamos a utilizar en la implement
package com.sena.test.IService;

import java.util.List;
import com.sena.test.Dto.UserDto;
import com.sena.test.Entity.User;

public interface IUserService {

    public List<User> findAll();
    public User findById(int id);
    String update(int id, UserDto userDto);
    public List<User> filterByName(String user_name);
    public String save(UserDto u);
    public String delete(int id);
}