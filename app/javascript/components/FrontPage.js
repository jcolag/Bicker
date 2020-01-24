import React from "react"
import PropTypes from "prop-types"
class FrontPage extends React.Component {
  render () {
    return (
      <React.Fragment>
        <div class="block">
	        <header class="header-group">
	          <img
	            class="main-logo"
	            src={this.props.logo}
	          />
	        </header>
	        <div>
	          <p>
	            Welcome to <b>{ this.props.name }</b>!
	          </p>
	          <p>
	            <b>{ this.props.name }</b> is an attempt to change
	            communications for the better by building on the
	            lessons of the past.  Among other things, you can
	            think of it as&hellip;
	            <ul>
	              <li>
	                Part e-mail,
	              </li>
	              <li>
	                Part forum,
	              </li>
	              <li>
	                Part bulletin board,
	              </li>
	              <li>
	                Part chat,
	              </li>
	              <li>
	                Part blog,
	              </li>
	              <li>
	                Part comment thread, and
	              </li>
	              <li>
	                Part document management system.
	              </li>
	            </ul>
	            &hellip;<i>but</i>, unlike most of those other systems,
	            it&rsquo;s intentionally designed to encourage better
	            behavior in conversations.  A reply with a list of answers
	            with no context should be a thing of the past.  Replying
	            to the wrong person should be a thing of the past.
	            Arguments over who said what should be a thing of the past.
	            Multiple respondants saying exactly the same thing should
	            <i>absolutely</i> be a thing of the past.  That&rsquo;s
	            the past.
	          </p>
	          <p>
	            <b>{ this.props.name }</b> is the future.  Well,
	            it&rsquo;s actually just one potential future of
	            many, but that&rsquo;s not nearly as pithy.
	          </p>
	        </div>
        </div>
      </React.Fragment>
    );
  }
}

FrontPage.propTypes = {
  name: PropTypes.string,
  logo: PropTypes.string
};
export default FrontPage
