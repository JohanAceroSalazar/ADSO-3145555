package com.sena.test.Controller.InventoryController;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.sena.test.Dto.InventoryDto.CategoryDto;
import com.sena.test.Entity.Inventory.Category;
import com.sena.test.IService.IInventoryService.ICategoryService;

@RestController
@RequestMapping("/category")
public class CategoryController {

    @Autowired
    private ICategoryService service;

    @GetMapping("")
    public ResponseEntity<Object>findAll(){
        return new ResponseEntity<Object>
        (service.findAll(),HttpStatus.OK);
    }

    @PostMapping("/id")
    public ResponseEntity<Object>save(
        @RequestBody CategoryDto c){
            service.save(c);
            return new ResponseEntity<Object>
            ("Se guardo exitosamente",HttpStatus.OK);
        }

    @GetMapping("{id}")
    public ResponseEntity<Object>findById(
        @PathVariable int id){
            Category category = service.findById(id);
            return new ResponseEntity<Object>
            (category,HttpStatus.OK);
        }

    @PutMapping("/{id}")
    public ResponseEntity<Object> update(
        @PathVariable int id,
        @RequestBody CategoryDto categoryDto){

        return new ResponseEntity<>(
            service.update(id, categoryDto),
            HttpStatus.OK);
        }

    @GetMapping("filterByCategory/{Category}")
    public ResponseEntity<Object>filterByNameCategory(
        @PathVariable String name_Category){
            List<Category> category = service.filterByNameCategory(name_Category);
            return new ResponseEntity<Object>
            (category,HttpStatus.OK);
        }

    @DeleteMapping("{id}")
    public ResponseEntity<Object> delete(
        @PathVariable int id){
            service.delete(id);
            return new ResponseEntity<Object>
            ("Se elimino correctamente",HttpStatus.OK);
        }
}