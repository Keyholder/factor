! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs namespaces kernel sequences sets
destructors combinators fry
io.encodings.utf8 io.encodings.string io.binary random
checksums checksums.sha2
html.forms
http.server
http.server.filters
http.server.dispatchers
furnace
furnace.actions
furnace.redirection
furnace.boilerplate
furnace.auth.providers
furnace.auth.providers.db ;
IN: furnace.auth

SYMBOL: logged-in-user

: logged-in? ( -- ? ) logged-in-user get >boolean ;

GENERIC: init-user-profile ( responder -- )

M: object init-user-profile drop ;

M: dispatcher init-user-profile
    default>> init-user-profile ;

M: filter-responder init-user-profile
    responder>> init-user-profile ;

: have-capability? ( capability -- ? )
    logged-in-user get capabilities>> member? ;

: profile ( -- assoc ) logged-in-user get profile>> ;

: user-changed ( -- )
    logged-in-user get t >>changed? drop ;

: uget ( key -- value )
    profile at ;

: uset ( value key -- )
    profile set-at
    user-changed ;

: uchange ( quot key -- )
    profile swap change-at
    user-changed ; inline

SYMBOL: capabilities

V{ } clone capabilities set-global

: define-capability ( word -- ) capabilities get adjoin ;

TUPLE: realm < dispatcher name users checksum secure ;

GENERIC: login-required* ( realm -- response )

GENERIC: logged-in-username ( realm -- username )

: login-required ( -- * ) realm get login-required* exit-with ;

: new-realm ( responder name class -- realm )
    new-dispatcher
        swap >>name
        swap >>default
        users-in-db >>users
        sha-256 >>checksum
        t >>secure ; inline

: users ( -- provider )
    realm get users>> ;

TUPLE: user-saver user ;

C: <user-saver> user-saver

M: user-saver dispose
    user>> dup changed?>> [ users update-user ] [ drop ] if ;

: save-user-after ( user -- )
    <user-saver> &dispose drop ;

: init-user ( user -- )
    [ [ logged-in-user set ] [ save-user-after ] bi ] when* ;

M: realm call-responder* ( path responder -- response )
    dup realm set
    dup logged-in-username dup [ users get-user ] when init-user
    call-next-method ;

: encode-password ( string salt -- bytes )
    [ utf8 encode ] [ 4 >be ] bi* append
    realm get checksum>> checksum-bytes ;

: >>encoded-password ( user string -- user )
    32 random-bits [ encode-password ] keep
    [ >>password ] [ >>salt ] bi* ; inline

: valid-login? ( password user -- ? )
    [ salt>> encode-password ] [ password>> ] bi = ;

: check-login ( password username -- user/f )
    users get-user dup [ [ valid-login? ] keep and ] [ 2drop f ] if ;

: if-secure-realm ( quot -- )
    realm get secure>> [ if-secure ] [ call ] if ; inline

TUPLE: secure-realm-only < filter-responder ;

C: <secure-realm-only> secure-realm-only

M: secure-realm-only call-responder*
    '[ , , call-next-method ] if-secure-realm ;

TUPLE: protected < filter-responder description capabilities ;

: <protected> ( responder -- protected )
    protected new
        swap >>responder ;

: check-capabilities ( responder user/f -- ? )
    {
        { [ dup not ] [ 2drop f ] }
        { [ dup deleted>> 1 = ] [ 2drop f ] }
        [ [ capabilities>> ] bi@ subset? ]
    } cond ;

M: protected call-responder* ( path responder -- response )
    '[
        , ,
        dup protected set
        dup logged-in-user get check-capabilities
        [ call-next-method ] [ 2drop realm get login-required* ] if
    ] if-secure-realm ;

: <auth-boilerplate> ( responder -- responder' )
    <boilerplate> { realm "boilerplate" } >>template ;

: password-mismatch ( -- * )
    "passwords do not match" validation-error
    validation-failed ;

: same-password-twice ( -- )
    "new-password" value "verify-password" value =
    [ password-mismatch ] unless ;

: user-exists ( -- * )
    "username taken" validation-error
    validation-failed ;
