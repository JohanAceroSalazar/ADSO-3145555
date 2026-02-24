package com.sena.test.IService.Imple;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sena.test.Dto.RoleDto;
import com.sena.test.Entity.Role;
import com.sena.test.IRepository.RoleRepository;
import com.sena.test.IService.IRoleService;

@Service
public class RoleServiceImple implements IRoleService {

    @Autowired
    private RoleRepository repo;

    @Override
    public List<Role> findAll(){
        return repo.findAll();
    }

    @Override
    public Role findById(int id_role){
        return repo.findById(id_role).orElse(null);
    }

    @Override
    public String update(int id, RoleDto roleDto){
        Role role = repo.findById(id).orElse(null);

        if(role == null){
            return "Este rol no existe";
        }

        role.setRole(roleDto.getRole());
        repo.save(role);
        return "Rol actualizado correctamente";
    }

    @Override
    public List<Role> findByRole(String role){
        return repo.filterByRole(role);
    }

    public Role dtoToEntity(RoleDto roleDto){
        return new Role(
            roleDto.getId(),
            roleDto.getRole()
        );
    }

    public Role entityToRole(Role role){
        return new Role(
            role.getId_role(),
            role.getRole()
        );
    }

    @Override
    public String save(RoleDto roleDto){
        Role role = dtoToEntity(roleDto);
        repo.save(role);
        return "El rol se guardo exitosamente";
    }

    @Override
    public String delete(int id){
        repo.deleteById(id);
        return null;
    }
}