package com.sena.test.Controller.InventoryController;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.sena.test.Dto.InventoryDto.ProductDto;
import com.sena.test.Entity.Inventory.Product;
import com.sena.test.IService.IInventoryService.IProductService;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;

@RestController
@RequestMapping("/product")
public class ProductController {

    @Autowired
    private IProductService service;

    @GetMapping("")
    public ResponseEntity<Object>findAll(){
        return new ResponseEntity<Object>
        (service.findAll(),HttpStatus.OK);
    }

    @PostMapping("/id")
    public ResponseEntity<Object>save(
        @RequestBody ProductDto p){
            service.save(p);
            return new ResponseEntity<Object>
            ("Se guardo exitosamente",HttpStatus.OK);
        }

    @GetMapping("{id}")
    public ResponseEntity<Object>findById(
        @PathVariable int id){
            Product product = service.findById(id);
            return new ResponseEntity<Object>
            (product,HttpStatus.OK);
        }

    @PutMapping("/{id}")
    public ResponseEntity<Object> update(
        @PathVariable int id,
        @RequestBody ProductDto ProductDto){

        return new ResponseEntity<>(
            service.update(id, ProductDto),
            HttpStatus.OK);
        }

    @GetMapping("filterByProduct/{product}")
    public ResponseEntity<Object>filterByNameProduct(
        @PathVariable String name_product){
            List<Product> product = service.filterByNameProduct(name_product);
            return new ResponseEntity<Object>
            (product,HttpStatus.OK);
        }

    @DeleteMapping("{id}")
    public ResponseEntity<Object> delete(
        @PathVariable int id){
            service.delete(id);
            return new ResponseEntity<Object>
            ("Se elimino correctamente",HttpStatus.OK);
        }
    }