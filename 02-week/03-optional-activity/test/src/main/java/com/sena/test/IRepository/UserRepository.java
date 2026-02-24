//Se conecta con la base de datos
package com.sena.test.IRepository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import com.sena.test.Entity.User;

@Repository
public interface UserRepository extends JpaRepository<User, Integer> {

    @Query(""
			+ "SELECT "
			+ "u "
			+ "FROM "
			+ "users u "
			+ "WHERE "
			+ "u.user_name like %?1%"
			)
	public List<User>filterByName(String user_name);
}